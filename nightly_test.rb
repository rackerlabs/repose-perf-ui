#!/usr/bin/env ruby

require 'fog'
require_relative './Models/environment.rb'
require_relative './Models/template.rb'
require 'redis'
require 'trollop'
require 'json'
require 'nokogiri'
require 'erb'
require 'logging'
require 'rbconfig'
require 'yaml'
require 'net/scp'
require 'rest_client'

RETRY_COUNT = 3

def get_server_ips(lb_name, logger, env, test_id)
  run_succeeded = false
  retry_counter = 0
  while !run_succeeded && retry_counter < RETRY_COUNT
    begin
      logger.debug "load balancer name: #{lb_name}_#{test_id}"
      lb_ip = env.lb_service.load_balancers.find do |lb| 
        lb.name =~ /#{Regexp.escape(lb_name)}_#{Regexp.escape(test_id.to_s)}/ 
      end.virtual_ips.find do |ip| 
        ip.ip_version == 'IPV4' && ip.type == 'PUBLIC' 
      end.address
  
      logger.debug "load balancer ip: #{lb_ip}"
  
      node_ips = env.lb_service.load_balancers.find do |lb| 
        lb.name =~ /#{Regexp.escape(lb_name)}_#{Regexp.escape(test_id.to_s)}/ 
      end.nodes.map do |ip| 
        ip.address 
      end
      run_succeeded = true
    rescue Exception => e
      logger.info e
      logger.info e.backtrace
      retry_counter = retry_counter + 1  
    end
  end
  logger.debug "nodes: #{node_ips}"
  
  {:lb => lb_ip, :nodes => node_ips}
end

def get_test_ip(logger, env, test_id)
  run_succeeded = false
  retry_counter = 0
  while !run_succeeded && retry_counter < RETRY_COUNT
    begin
      test_agent = env.service.servers.find {|server| server.name =~ /test-agent-id-#{Regexp.escape(test_id.to_s)}/}.ipv4_address
      logger.info "test agent: #{test_agent}"
      run_succeeded = true
    rescue Exception => e
      logger.info e
      logger.info e.backtrace
      retry_counter = retry_counter + 1  
    end
  end
  test_agent
end

def get_slave_test_ip(logger, env, test_id)
  run_succeeded = false
  retry_counter = 0
  while !run_succeeded && retry_counter < RETRY_COUNT
    begin
      
      test_agent_list = env.service.servers.find_all {|server| logger.info server.name ;  server.name =~ /slave-test-agent-id-#{Regexp.escape(test_id.to_s)}/}.map {|server| server.ipv4_address}
      logger.info "slave test agent list: #{test_agent_list}"
      run_succeeded = true
    rescue Exception => e
      logger.info e
      logger.info e.backtrace
      retry_counter = retry_counter + 1  
    end
  end
  test_agent_list
end

environment_hash = {
 :atom_hopper => :iad,
 :translation => :iad,
 :identity => :iad,
 :dbaas => :iad,
 :auto_scale => :dfw,
 :psl => :dfw,
 :cloud_queues => :dfw
}


Logging.color_scheme( 'bright',
  :levels => {
    :info  => :green,
    :warn  => :yellow,
    :error => :red,
    :fatal => [:white, :on_red]
  },
  :date => :blue,
  :logger => :cyan,
  :message => :magenta
)
logger = Logging.logger(STDOUT)
logger.level = :debug

config = YAML.load_file(File.expand_path("config/config.yaml", Dir.pwd))
logger.debug "configuration file: #{config}"

=begin
-- NEEDS:
	1. get application
	2. get sub application
	3. get test type
    	4. get length
	5. get description
	6. get flavor type
	7. get release
	8. get runner
	9. get name
-- STEPS:
	1. get the test server and 2 cloud servers
	2. cloud servers:
		1. log in and execute download-repose for either snapshot or release (if it's there)
		2. start jmxtrans
		3. start sar
	3. test server
		1. upload test script 
		2. start with parameters passed in
=end

opts = Trollop::options do
  version "fog wrapper for repose pt 0.0.1 - 2013 Dimitry Ushakov"
  banner <<-EOS
Responsible for spinning up vm's with repose and tests.  Tightly couple to the machine it's running on as it's utilizing specific directories.  Linux only.
Attributes:
  app - this is an application name.  always repose
  sub_app - this is the sub app name. this is the configuration id (atom_hopper, translation, etc.)
  test_type - can either be load, adhoc, duration, or stress
  action - either start or stop
  length - load test length in minutes
  description - description of the test
  name - test name
  release - specify release.  We'll be testing against 2.11.0
  branch - specifies branch.  Defaults to master
  flavor_type - can either be original or performance
  runner - which runner to use to run the test (jmeter, gatling, etc)
  test_id - specifies test id
  with_repose - whether repose or origin target server
Usage:
       nightly_test --app repose --sub-app <sub app name> --test-type <load|duration|benchmark> --action <start|stop> --length 60 --description <some desc> --release master --branch master --flavor-type performance --runner jmeter --test-id 0 --with-repose true
where [options] are:
EOS
  opt :app, "App name", :default => "repose"
  opt :sub_app, "Sub app name", :type => :string
  opt :test_type, "Test type", :default => "load"
  opt :action, "Action", :type => :string
  opt :length, "Length in minutes", :type => :int
  opt :description, "Test description", :type => :string
  opt :name, "Test name", :type => :string
  opt :release, "Specify Release", :type => :string
  opt :branch, "Specify Branch", :type => :string
  opt :flavor_type, "Flavor type", :type => :string
  opt :runner, "Runner", :type => :string
  opt :test_id, "Test id", :type => :int
  opt :with_repose, "Boolean repose", :type => :boolean
  opt :extra_ear, "Extra ears containing filters not in Repose", :type => :string
end

Trollop::die :action, "must be specified" unless opts[:action]
Trollop::die :sub_app, "must be specified" unless opts[:sub_app]
Trollop::die :test_type, "must be specified" unless opts[:test_type]
Trollop::die :name, "must be specified" unless opts[:name]

logger.debug opts

if opts[:action] == 'stop'
  
  logger.debug "config: #{config} and logger: #{logger}"
  env = SnapshotComparer::Models::Environment.new(config, logger)
  env.connect(environment_hash[opts[:sub_app].to_sym])
  env.load_balance_connect(environment_hash[opts[:sub_app].to_sym])

  test_agent = get_test_ip(logger, env, opts[:test_id])

  run_succeeded = false
  retry_counter = 0
  while !run_succeeded && retry_counter < RETRY_COUNT
    begin
      Net::SSH.start(test_agent, 'root') do |ssh|
        ssh.exec!("/home/apache/apache-jmeter-2.10/bin/shutdown.sh")
      end
      run_succeeded = true
    rescue Exception => e
      logger.info e
      logger.info e.backtrace
      retry_counter = retry_counter + 1
    end
  end

  if opts[:flavor_type] == 'performance' 
    if opts[:with_repose]
      #performance with repose!
      logger.debug "we just ran a test on performance flavor with repose"
      server_ip_info = get_server_ips("repose_lb_perf_flavors_withrepose", logger, env, opts[:test_id])
    else
      #performance without repose!
      logger.debug "we just ran a test on performance flavor without repose"
      server_ip_info = get_server_ips("repose_lb_perf_flavors_withoutrepose", logger, env, opts[:test_id])
    end
  else
    if opts[:with_repose]
      #original with repose!
      logger.debug "we just ran a test on original flavor with repose"
      server_ip_info = get_server_ips("repose_lb_original_withrepose", logger, env, opts[:test_id])
    else
      #original with repose!
      logger.debug "we just ran a test on original flavor without repose"
      server_ip_info = get_server_ips("repose_lb_original_withoutrepose", logger, env, opts[:test_id])
    end
  end

  #stop
  if File.exists?(File.expand_path("test_execution.yaml", Dir.pwd))
    test_yaml = YAML.load_file(File.expand_path("test_execution.yaml", Dir.pwd))
    if test_yaml and test_yaml.find { |t| t.has_key?("name") and t["name"] == opts[:app]}
      app_name = test_yaml.find { |t| t.has_key?("name") and t["name"] == opts[:app]}
      if app_name and app_name["sub_app"].find {|t|  t.has_key?("name") and t["name"] == opts[:sub_app]}
        sub_app_name = app_name["sub_app"].find {|t|  t.has_key?("name") and t["name"] == opts[:sub_app]}
        if sub_app_name and sub_app_name["test_type"].find {|t| t.has_key?("name") and t["name"] == opts[:test_type]}
          test_type = sub_app_name["test_type"].find {|t| t.has_key?("name") and t["name"] == opts[:test_type]}
          if opts[:with_repose]
            guid = test_type["repose_guid"]
          else
            guid = test_type["origin_guid"]
          end
        end
      end
    end
  end

  raise ArgumentError, "no guid" unless guid
  
  request_body = {
    "guid" =>  guid,
    "servers" => {
      "results" => {
        "server" => test_agent,
        "user" => "root",
        "path" => "/home/apache/test/summary.log"
      }
    }
  }

  request_body["plugins"] = []
  if opts[:with_repose]
    request_body["servers"]["config"] = {
      "server" => server_ip_info[:nodes].first,
      "user" => "root",
      "path" => "/home/repose/configs/"
    }
    repose_jmx_servers = []
    server_ip_info[:nodes].each do |server|
      repose_jmx_servers << {
        "server" => server,
        "user" => "root",
        "path" => "/home/repose/logs/jmxdata.out"
      } 
    end
    repose_log_servers = []
    server_ip_info[:nodes].each do |server|
      repose_log_servers << {
        "server" => server,
        "user" => "root",
        "path" => "/home/repose/logs/repose.log"
      } 
    end
    request_body["plugins"] << 
      {
      "id" => "repose_jmx_plugin",
      "servers" => repose_jmx_servers
      }
    request_body["plugins"] << 
     {
     "id" => "file_plugin",
     "type" => "blob",
     "servers" => repose_log_servers
     }
  end
  sysstats_servers = []
  server_ip_info[:nodes].each do |server|
    sysstats_servers << {
      "server" => server,
      "user" => "root",
      "path" => "/home/repose/logs/sysstats.log"
    } 
  end
  request_body["plugins"] << 
    {
    "id" => "sysstats_plugin",
    "servers" => sysstats_servers
    }


  logger.info "http://localhost/#{opts[:app]}/applications/#{opts[:sub_app]}/#{opts[:test_type]}/stop"
  logger.info request_body.to_json
  begin
    response = RestClient::Request.execute(:method => :post, :url => "http://localhost/#{opts[:app]}/applications/#{opts[:sub_app]}/#{opts[:test_type]}/stop", :timeout => -1,  :payload => request_body.to_json)
  rescue Exception => e
    p e.backtrace
  end

  logger.debug response
  logger.debug response.code

  server_ip_info[:nodes].each do |server|
    logger.info server
    logger.debug "with repose: #{opts[:with_repose]}"
    if opts[:with_repose]
      logger.info "stop jmxtrans"
      system "ssh root@#{server} 'cd /usr/share/jmxtrans ; ./jmxtrans.sh stop '"
      system "ssh root@#{server} -f 'killall java '"
      
      system "ssh root@#{server} 'rm -rf /home/repose/configs/* '" 
      system "ssh root@#{server} 'rm -rf /home/repose/usr/share/repose/repose-valve.jar '" 
      system "ssh root@#{server} 'rm -rf /home/repose/usr/share/repose/filters/* '" 
      system "ssh root@#{server} 'rm -rf /home/repose/logs/* '" 
    end
    system "ssh root@#{server} -f 'killall node '"
    system "ssh root@#{server} -f 'killall sar '"
    system "ssh root@#{server} -f 'service sysstat stop '"
  end

  logger.info "remove the used values from yaml"
  if File.exists?(File.expand_path("test_execution.yaml", Dir.pwd))
    test_yaml = YAML.load_file(File.expand_path("test_execution.yaml", Dir.pwd))
    if test_yaml and test_yaml.find { |t| t.has_key?("name") and t["name"] == opts[:app]}
      app_name = test_yaml.find { |t| t.has_key?("name") and t["name"] == opts[:app]}
      if app_name and app_name["sub_app"].find {|t|  t.has_key?("name") and t["name"] == opts[:sub_app]}
        sub_app_name = app_name["sub_app"].find {|t|  t.has_key?("name") and t["name"] == opts[:sub_app]}
        if sub_app_name and sub_app_name["test_type"].find {|t| t.has_key?("name") and t["name"] == opts[:test_type]}
          test_type = sub_app_name["test_type"].find {|t| t.has_key?("name") and t["name"] == opts[:test_type]}
          sub_app_name["test_type"].delete(test_type) unless opts[:with_repose]
        end
      end
    end
  end
  
  logger.info "yaml content: #{test_yaml.to_yaml}"

  File.open(File.expand_path("test_execution.yaml", Dir.pwd), 'w') {|f| f.write test_yaml.to_yaml }

  Net::SSH.start(test_agent, 'root') do |ssh|
    ssh.exec!("rm -rf /home/apache/test/*")
  end
elsif opts[:action] == 'start'
=begin
-- STEPS:
        1. get the test server and 2 cloud servers
        2. cloud servers:
                1. log in and execute download-repose for either snapshot or release (if it's there) << done but need to fix errorz! (and add a loop that checks response from regular version call to make sure it's up...non 500)
                2. copy all configs over << done
                3. copy responders over
                3. start jmxtrans << done
                4. start sar 
   		5. start repose << done
        3. test server
                1. upload test script
                2. start with parameters passed in
=end
  logger.debug "config: #{config} and logger: #{logger}"
  logger.info "spin up necessary servers (2 for target and 1 for test) from specific environment"
  env = SnapshotComparer::Models::Environment.new(config, logger)
  env.connect(environment_hash[opts[:sub_app].to_sym])
  env.load_balance_connect(environment_hash[opts[:sub_app].to_sym])
  
  if opts[:flavor_type] == 'performance' 
    if opts[:with_repose]
      #performance with repose!
      logger.debug "we are setting up a test on performance flavor with repose"
      server_ip_info = get_server_ips("repose_lb_perf_flavors_withrepose", logger, env,opts[:test_id])
    else
      #performance without repose!
      logger.debug "we are setting up a test on performance flavor without repose"
      server_ip_info = get_server_ips("repose_lb_perf_flavors_withoutrepose", logger, env, opts[:test_id])
    end
  else
    if opts[:with_repose]
      #original with repose!
      logger.debug "we are setting up a test on original flavor with repose"
      server_ip_info = get_server_ips("repose_lb_original_withrepose", logger, env, opts[:test_id])
    else
      #original with repose!
      logger.debug "we are setting up a test on original flavor without repose"
      server_ip_info = get_server_ips("repose_lb_original_withoutrepose", logger, env, opts[:test_id])
    end
  end

  slave_test_agent_list = get_slave_test_ip(logger,env,opts[:test_id])
  logger.info "slaves: #{slave_test_agent_list.inspect}"

  logger.info "get into redis"
  redis = Redis.new({:host => config['redis']['host'], :port => config['redis']['port'], :db => config['redis']['db']})
  logger.debug "redis: #{redis}"
  config_list = redis.lrange("#{opts[:app]}:#{opts[:sub_app]}:setup:configs", 0, -1)

  guid = SecureRandom.uuid
  
  logger.info "get meta information"

  meta_information = redis.hgetall("#{opts[:app]}:#{opts[:sub_app]}:setup:meta")
  main_responders = meta_information.select {|m,_| m =~ /responder\|main\|/}
  secondary_responders = meta_information.select {|m,_| m =~ /responder\|secondary\|/}
  logger.info "main responders: #{main_responders}"
  logger.info "secondary responders: #{secondary_responders}"


  if opts[:with_repose] and opts[:release] and opts[:release] == 'master'
    branch = opts[:branch] ? opts[:branch] : 'master'
    system "rm -rf ~/repose_repo/repose ; mkdir ~/repose_repo/repose ; cd ~/repose_repo/repose ; git init ; git pull https://github.com/rackerlabs/repose #{branch} ; mvn clean install -U -DskipTests; "
  end

  is_started_successfully = false

  server_ip_info[:nodes].each do |server|
    if opts[:with_repose]
      config_list.each do |config_data|
        #first, download from remote

        if config['storage_info']['destination'] == 'localhost'
          logger.info "moving over: #{JSON.parse(config_data)['name']}"
          if JSON.parse(config_data)['name'] == 'system-model.cfg.xml'
            system_model_contents = SnapshotComparer::SystemModelTemplate.new(server_ip_info[:nodes],File.read("#{config['storage_info']['path']}/#{JSON.parse(config_data)['location']}")).render

            tmp_dir = "/tmp/#{guid}/"
            FileUtils.mkpath tmp_dir unless File.exists?(tmp_dir)
            File.open("/tmp/#{guid}/system-model.cfg.xml", 'w') { |f| f.write(system_model_contents) }

            Net::SCP.upload!(
              server, 
              'root', 
              "/tmp/#{guid}/system-model.cfg.xml", 
              "/home/repose/configs/", 
              {:recursive => true, :verbose => true }
            )
          
            FileUtils.rm_rf("/tmp/#{guid}")
          elsif JSON.parse(config_data)['name'] == 'dist-datastore.cfg.xml'
            system_model_contents = SnapshotComparer::SystemModelTemplate.new(server_ip_info[:nodes],File.read("#{config['storage_info']['path']}/#{JSON.parse(config_data)['location']}")).render

            tmp_dir = "/tmp/#{guid}/"
            FileUtils.mkpath tmp_dir unless File.exists?(tmp_dir)
            File.open("/tmp/#{guid}/dist-datastore.cfg.xml", 'w') { |f| f.write(system_model_contents) }

            Net::SCP.upload!(
              server,
              'root',
              "/tmp/#{guid}/dist-datastore.cfg.xml",
              "/home/repose/configs/",
              {:recursive => true, :verbose => true }
            ) 

            FileUtils.rm_rf("/tmp/#{guid}")
          else
            name_to_save = JSON.parse(config_data)['location'].gsub(/^\/#{Regexp.escape(config['storage_info']['prefix'])}\/#{Regexp.escape(opts[:app])}\/#{Regexp.escape(opts[:sub_app])}\/setup\/configs\//,"")
            directory_to_save = File.dirname(name_to_save)
            Net::SSH.start(server, 'root') do |ssh|
              ssh.exec!("mkdir -p /home/repose/configs/#{directory_to_save}")
            end
            Net::SCP.upload!(
              server, 
              'root', 
              "#{config['storage_info']['path']}/#{JSON.parse(config_data)['location']}", 
              "/home/repose/configs/#{directory_to_save}", 
              {:recursive => true, :verbose => true }
            ) 
          end
        else
          tmp_dir = "/tmp/#{guid}/"
          FileUtils.mkpath tmp_dir unless File.exists?(tmp_dir)
          Net::SCP.download!(
            config['storage_info']['destination'], 
            config['storage_info']['user'], 
            JSON.parse(config_data)['location'], 
            tmp_dir, 
            {:recursive => true,
              :verbose => Logger::DEBUG}
          ) 
        
          #second, upload to remote
          Net::SCP.upload!(
            server, 
            'root', 
            "/tmp/#{guid}/", 
            "/home/repose/configs/", 
            {:recursive => true, :verbose => true }
          )
        
          FileUtils.rm_rf("/tmp/#{guid}")
        end
      end
    end
  
    if opts[:with_repose]
      logger.info "download repose"

      logger.debug "i only care about jmx plugin right now"
      plugin_list = redis.hget("#{opts[:app]}:#{opts[:sub_app]}:setup:meta:plugins", "ReposeJMXPlugin")
      plugin_list_json = JSON.parse(plugin_list) if plugin_list
     
      plugin_list_json.each do |plugin|
        if config['storage_info']['destination'] == 'localhost'
          logger.info "moving over: #{plugin['name']}"
          Net::SSH.start(server, 'root') do |ssh|
            ssh.exec!("mkdir -p /usr/share/jmxtrans/")
          end
          Net::SCP.upload!(
            server, 
            'root', 
            "#{config['storage_info']['path']}/#{plugin['location']}", 
            "/usr/share/jmxtrans/", 
            {:recursive => true, :verbose => true }
          )
        else
          tmp_dir = "/tmp/#{guid}/"
          FileUtils.mkpath tmp_dir unless File.exists?(tmp_dir)
          Net::SCP.download!(
            config['storage_info']['destination'], 
            config['storage_info']['user'], 
            plugin['location'], 
            tmp_dir, 
            {:recursive => true,
              :verbose => Logger::DEBUG}
          ) 
      
          #second, upload to remote
          Net::SCP.upload!(
            server, 
            'root', 
            "/tmp/#{guid}/", 
            "/usr/share/jmxtrans/", 
            {:recursive => true, :verbose => true }
          )
        
          FileUtils.rm_rf("/tmp/#{guid}")
        end
 
        logger.info "stop jmxtrans"
        system "ssh root@#{server} -f 'cd /usr/share/jmxtrans ; ./jmxtrans.sh stop '"
        logger.debug "start jmxtrans"
        system "ssh root@#{server} -f 'cd /usr/share/jmxtrans ; ./jmxtrans.sh start #{plugin['name']} '" 
      end if plugin_list_json

      if opts[:release]
        if opts[:extra_ear]
          opts[:extra_ear].split(',').each do |extra_ear|
            Net::SCP.upload!(
               server,
              'root',
              extra_ear,
              "/home/repose/usr/share/repose/filters/#{File.basename(extra_ear)}",
              {:recursive => true, :verbose => true }
            )
          end
        end
        if opts[:release] == 'master'
          logger.info "download master version"
          
          filter_bundle_ear = Dir.glob("/root/repose_repo/repose/repose-aggregator/components/filters/filter-bundle/target/*.ear").first
          extension_bundle_ear = Dir.glob("/root/repose_repo/repose/repose-aggregator/extensions/extensions-filter-bundle/target/*.ear").first
          logger.info "filter bundle: #{filter_bundle_ear}"
 	        logger.info "extension filter bundle: #{extension_bundle_ear}"
	        logger.info "server: #{server}"

          Net::SSH.start(server, 'root') do |ssh|
            ssh.exec!("mkdir -p /home/repose/usr/share/repose/filters")
          end

          Net::SCP.upload!(
            server, 
            'root', 
            filter_bundle_ear, 
            "/home/repose/usr/share/repose/filters/filter-bundle.ear", 
            {:recursive => true, :verbose => true }
          )
          
          Net::SCP.upload!(
            server, 
            'root', 
            extension_bundle_ear, 
            "/home/repose/usr/share/repose/filters/extensions-filter-bundle.ear", 
            {:recursive => true, :verbose => true }
          )
          
          Net::SCP.upload!(
            server, 
            'root', 
            "/root/repose_repo/repose/repose-aggregator/core/valve/target/repose-valve.jar", 
            "/home/repose/usr/share/repose/repose-valve.jar", 
            {:recursive => true, :verbose => true }
          )
        else
          system "ssh root@#{server} 'cd /home/repose ; virtualenv . ; source bin/activate ; pip install requests ; pip install narwhal ; download-repose --version #{opts[:release]}'"
        end
      else 
        logger.info "download snapshot version"
        system "ssh root@#{server} 'cd /home/repose ; virtualenv . ; source bin/activate ; pip install requests ; pip install narwhal ; download-repose --snapshot'"      
      end
    end
    
    logger.info "upload responders"
    main_responders.each do |key, responder|
      responder_json = JSON.parse(responder)
      name = responder_json['name']
      location = responder_json['location']
      if config['storage_info']['destination'] == 'localhost'
        Net::SSH.start(server, 'root') do |ssh|
          ssh.exec!("mkdir -p /home/mocks")
        end
        logger.info "#{config['storage_info']['path']}/#{location}"
        Net::SCP.upload!(
          server, 
          'root', 
          "#{config['storage_info']['path']}#{location}", 
          "/home/mocks/", 
          {:recursive => true, :verbose => true }
        )
      else
        tmp_dir = "/tmp/#{guid}/"
        FileUtils.mkpath tmp_dir unless File.exists?(tmp_dir)
        Net::SCP.download!(
          config['storage_info']['destination'], 
          config['storage_info']['user'], 
          location, 
          tmp_dir, 
          {:recursive => true,
            :verbose => Logger::DEBUG}
        ) 
    
        #second, upload to remote
        Net::SCP.upload!(
          server, 
          'root', 
          "/tmp/#{guid}/#{name}", 
          "/home/mocks/", 
          {:recursive => true, :verbose => true }
        )
      
        FileUtils.rm_rf("/tmp/#{guid}")
      end
      system "ssh root@#{server} -f 'nohup node /home/mocks/#{name} & '"
    end if opts[:with_repose] || (!opts[:with_repose] && !secondary_responders) || (!opts[:with_repose] && secondary_responders && secondary_responders.length == 0)
    logger.info "secondary responders: #{secondary_responders}"
    logger.debug !opts[:with_repose] && secondary_responders
    secondary_responders.each do |key, responder|
      responder_json = JSON.parse(responder)
      name = responder_json['name']
      location = responder_json['location']
      if config['storage_info']['destination'] == 'localhost'
        Net::SSH.start(server, 'root') do |ssh|
          ssh.exec!("mkdir -p /home/mocks")
        end
        logger.info "#{config['storage_info']['path']}/#{location}"
        Net::SCP.upload!(
          server, 
          'root', 
          "#{config['storage_info']['path']}/#{location}", 
          "/home/mocks/", 
          {:recursive => true, :verbose => true }
        )
      else
        tmp_dir = "/tmp/#{guid}/"
        FileUtils.mkpath tmp_dir unless File.exists?(tmp_dir)
        Net::SCP.download!(
          config['storage_info']['destination'], 
          config['storage_info']['user'], 
          location, 
          tmp_dir, 
          {:recursive => true,
            :verbose => Logger::DEBUG}
        ) 
      
        #second, upload to remote
        Net::SCP.upload!(
          server, 
          'root', 
          "/tmp/#{guid}/#{name}", 
          "/home/mocks/", 
          {:recursive => true, :verbose => true }
        )
      
        FileUtils.rm_rf("/tmp/#{guid}")
      end
        
      system "ssh root@#{server} -f 'nohup node /home/mocks/#{name} & '"
    end if secondary_responders && !opts[:with_repose]

    logger.info "start logging sysstats"
    system "ssh root@#{server} -f 'sar -o /home/repose/logs/sysstats.log 30 >/dev/null 2>&1 & '"

    if opts[:with_repose]
      logger.info "start repose"
      system "ssh root@#{server} -f 'nohup java -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Xms4G -Xmx4G -jar /home/repose/usr/share/repose/repose-valve.jar -c /home/repose/configs/ -s 6666 start & '" 
       
      
      is_valid = false
      execution_tries = 0
      response = nil
      until is_valid || execution_tries > 100
        begin
          logger.info "execute: http://#{server}:7070 for test"
          response = Net::HTTP.get_response(URI("http://#{server}:7070"))
          logger.info "response - no exception: #{response}"
          response_code = response.code
          logger.info "response - no exception: #{response_code}"
          is_valid = response_code.to_i < 500
        rescue Exception => msg
          is_started_successfully = false
          logger.info "response - exception: #{response}"
          if response
            response_code = response.code
            logger.info "response - exception: #{response_code}"
            is_valid = response_code.to_i < 500
          end
          logger.info "connection exception: #{msg}"
        end
        sleep 1
        execution_tries = execution_tries + 1
        response = nil
      end
      logger.info "is valid: #{is_valid}"
      is_started_successfully = true if is_valid
      raise ArgumentError, "unable to start repose on #{server}" unless is_started_successfully
    end
  end

  test_agent = get_test_ip(logger, env, opts[:test_id])
  Net::SSH.start(test_agent, 'root') do |ssh|
    ssh.exec!("mkdir -p /home/apache/test")
    ssh.exec!("rm -rf /home/apache/test/*")
  end
  
  logger.info "get jmeter stuff from redis"
  test_json = redis.hget("#{opts[:app]}:#{opts[:sub_app]}:setup:meta", "test_#{opts[:test_type]}_#{opts[:runner]}")
  
  raise ArgumentError, "invalid test" unless test_json
  test_data = JSON.parse(test_json)
  
  test_script_list = redis.lrange("#{opts[:app]}:#{opts[:sub_app]}:tests:setup:script", 0, -1)
  raise ArgumentError, "no tests found" unless test_script_list
  
  test_script = JSON.parse(test_script_list.find {|s| parsed_result = JSON.parse(s) ; parsed_result['type'] == opts[:runner] and parsed_result['test'] == opts[:test_type]})
  if config['storage_info']['destination'] == 'localhost'
    Net::SCP.upload!(
      test_agent, 
      'root', 
      "#{config['storage_info']['path']}/#{test_script['location']}", 
      "/home/apache/test/"
    )
  else
    tmp_dir = "/tmp/#{guid}/"
    FileUtils.mkpath tmp_dir unless File.exists?(tmp_dir)
    Net::SCP.download!(
      config['storage_info']['destination'], 
      config['storage_info']['user'], 
      test_script['location'], 
      tmp_dir
    ) 

    #second, upload to remote
    Net::SCP.upload!(
      test_agent, 
      'root', 
      "/tmp/#{guid}/#{name}", 
      "/home/apache/test/"
    )

    FileUtils.rm_rf("/tmp/#{guid}")
  end

  host = server_ip_info[:lb]
  startdelay = test_data["startdelay"]
  rampup = test_data["rampup"]
  duration = opts[:length] ? opts[:length] : test_data["duration"]

  request_body = {"length" =>  duration, "name" => opts[:name], "runner" => opts[:runner] }
  request_body["description"] = opts[:description] if opts[:description]
  request_body["flavor_type"] = opts[:flavor_type] if opts[:flavor_type]
  request_body["release"] = opts[:release] if opts[:release]

  guid = nil
  if File.exists?(File.expand_path("test_execution.yaml", Dir.pwd)) && !opts[:with_repose]
    test_yaml = YAML.load_file(File.expand_path("test_execution.yaml", Dir.pwd))
    if test_yaml and test_yaml.find { |t| t.has_key?("name") and t["name"] == opts[:app]}
      app_name = test_yaml.find { |t| t.has_key?("name") and t["name"] == opts[:app]}
      if app_name and app_name["sub_app"].find {|t|  t.has_key?("name") and t["name"] == opts[:sub_app]}
        sub_app_name = app_name["sub_app"].find {|t|  t.has_key?("name") and t["name"] == opts[:sub_app]}
        if sub_app_name and sub_app_name["test_type"].find {|t| t.has_key?("name") and t["name"] == opts[:test_type]}
          test_type = sub_app_name["test_type"].find {|t| t.has_key?("name") and t["name"] == opts[:test_type]}
          guid = test_type["repose_guid"]
        end
      end
    end
  end
  
  request_body["comparison_guid"] = guid unless opts[:with_repose]


  logger.info "http://localhost/#{opts[:app]}/applications/#{opts[:sub_app]}/#{opts[:test_type]}/start"
  logger.info request_body.to_json
  response = RestClient.post "http://localhost/#{opts[:app]}/applications/#{opts[:sub_app]}/#{opts[:test_type]}/start", request_body.to_json
  logger.debug response
  logger.debug response.code

  raise ArgumentError unless response.code == 200

  if File.exists?(File.expand_path("test_execution.yaml", Dir.pwd))
    test_yaml = YAML.load_file(File.expand_path("test_execution.yaml", Dir.pwd))
    if test_yaml and test_yaml.find { |t| t.has_key?("name") and t["name"] == opts[:app]}
      app_name = test_yaml.find { |t| t.has_key?("name") and t["name"] == opts[:app]}
      if app_name and app_name["sub_app"].find {|t|  t.has_key?("name") and t["name"] == opts[:sub_app]}
        sub_app_name = app_name["sub_app"].find {|t|  t.has_key?("name") and t["name"] == opts[:sub_app]}
        if sub_app_name and sub_app_name["test_type"].find {|t| t.has_key?("name") and t["name"] == opts[:test_type]}
          test_type = sub_app_name["test_type"].find {|t| t.has_key?("name") and t["name"] == opts[:test_type]}
          if opts[:with_repose] and test_type.has_key?("repose_guid")
            raise ArgumentError, "already exists!"
          elsif !opts[:with_repose] && test_type.has_key?("origin_guid")
            raise ArgumentError, "already exists!"
          elsif opts[:with_repose]
            test_type["repose_guid"] = JSON.parse(response)["guid"]
          else
            test_type["origin_guid"] = JSON.parse(response)["guid"]
          end
        else
          if opts[:with_repose]
            sub_app_name["test_type"] << {
              "name" => opts[:test_type],
              "repose_guid" => JSON.parse(response)["guid"]
            }
          else
            raise ArgumentError, "no guid for repose!"
          end
        end
      else
        if opts[:with_repose]
          app_name["sub_app"] << {
            "name" => opts[:sub_app],
            "test_type" => [{
              "name" => opts[:test_type],
              "repose_guid" => JSON.parse(response)["guid"]
            }]
          }
        else
          raise ArgumentError, "no guid for repose!"
        end
      end
    else
      if opts[:with_repose]
        test_yaml << {
          "name" => opts[:app],
          "sub_app" => [{
            "name" => opts[:sub_app],
            "test_type" => [{
              "name" => opts[:test_type],
              "repose_guid" => JSON.parse(response)["guid"]
            }]
          }]
        }
      else
        raise ArgumentError, "no guid for repose!"
      end
    end
  else
    if opts[:with_repose]
      test_yaml = [{
        "name" => opts[:app],
        "sub_app" => [{
          "name" => opts[:sub_app],
          "test_type" => [{
            "name" => opts[:test_type],
            "repose_guid" => JSON.parse(response)["guid"]
          }]
        }]
      }]
    else
      raise ArgumentError, "no guid for repose!"
    end
  end

  logger.info "yaml content: #{test_yaml.to_yaml}"

  File.open(File.expand_path("test_execution.yaml", Dir.pwd), 'w') {|f| f.write test_yaml.to_yaml }

  test_duration = duration * 60
  case opts[:test_type]
    when "load"
      rampdown = test_data["rampdown"] 
      throughput = test_data["throughput"]
      slave_test_agent_list << test_agent
      logger.info "ssh root@#{test_agent} -f 'nohup /home/apache/apache-jmeter-2.10/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.10/bin/jmeter.properties -Ghost=#{host} -Gstartdelay=#{startdelay} -Grampup=#{rampup} -Gduration=#{test_duration} -Grampdown=#{rampdown} -Gthroughput=#{throughput} -Gport=80 -R #{slave_test_agent_list.join(',')} >> /home/apache/test/summary.log & '"
      system "ssh root@#{test_agent} -f 'nohup /home/apache/apache-jmeter-2.10/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.10/bin/jmeter.properties -Ghost=#{host} -Gstartdelay=#{startdelay} -Grampup=#{rampup} -Gduration=#{test_duration} -Grampdown=#{rampdown} -Gthroughput=#{throughput} -Gport=80 -l /home/apache/test/response.jtl -R #{slave_test_agent_list.join(',')} >> /home/apache/test/summary.log & '"
    when "adhoc"
      rampdown = test_data["rampdown"] 
      throughput = test_data["throughput"]
      slave_test_agent_list << test_agent
      logger.info "ssh root@#{test_agent} -f 'nohup /home/apache/apache-jmeter-2.10/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.10/bin/jmeter.properties -Ghost=#{host} -Gstartdelay=#{startdelay} -Grampup=#{rampup} -Gduration=#{test_duration} -Grampdown=#{rampdown} -Gthroughput=#{throughput} -Gport=80 -R #{slave_test_agent_list.join(',')} >> /home/apache/test/summary.log & '"
      system "ssh root@#{test_agent} -f 'nohup /home/apache/apache-jmeter-2.10/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.10/bin/jmeter.properties -Ghost=#{host} -Gstartdelay=#{startdelay} -Grampup=#{rampup} -Gduration=#{test_duration} -Grampdown=#{rampdown} -Gthroughput=#{throughput} -Gport=80 -l /home/apache/test/response.jtl -R #{slave_test_agent_list.join(',')} >> /home/apache/test/summary.log & '"
    when "stress"  
      rampup_threads = test_data["rampup_threads"]  
      maxthreads = test_data["maxthreads"]
      logger.info "ssh root@#{test_agent} -f 'nohup /home/apache/apache-jmeter-2.10/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.10/bin/jmeter.properties -Ghost=#{host} -Gstartdelay=#{startdelay} -Grampup=#{rampup} -Gduration=#{test_duration} -Grampup_threads=#{rampup_threads} -Gmaxthreads=#{maxthreads} -Gport=80 -l /home/apache/test/response.jtl -R #{test_agent},166.78.152.90 >> /home/apache/test/summary.log & '"
      system "ssh root@#{test_agent} -f 'nohup /home/apache/apache-jmeter-2.10/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -R 162.209.124.170,162.209.124.104,162.209.99.151,162.209.97.222,162.209.103.84 -p /home/apache/apache-jmeter-2.10/bin/jmeter.properties -Ghost=#{host} -Gstartdelay=#{startdelay} -Grampup=#{rampup} -Gduration=#{test_duration} -Grampup_threads=#{rampup_threads} -Gmaxthreads=#{maxthreads} -Gport=80 -R #{test_agent},166.78.152.90 >> /home/apache/test/summary.log & '"

      sleep(60)
      logger.info Net::SSH.start(test_agent,'root') {|ssh| ssh.exec!("lsof -i :4445")}
      total_running_time = 0
      while Net::SSH.start(test_agent,'root') {|ssh| ssh.exec!("lsof -i :4445")} and total_running_time < 3600
        sleep(60)
        total_running_time = total_running_time + 60
        logger.info Net::SSH.start(test_agent,'root') {|ssh| ssh.exec!("lsof -i :4445")}
        logger.info total_running_time
      end
    else
      raise ArgumentError, "invalid test type"
    end

end
