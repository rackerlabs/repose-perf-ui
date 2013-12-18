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

def get_server_ips(lb_name, logger, env)
  logger.debug "load balancer name: #{lb_name}"
  lb_ip = env.lb_service.load_balancers.find do |lb| 
    lb.name =~ /#{Regexp.escape(lb_name)}/ 
  end.virtual_ips.find do |ip| 
    ip.ip_version == 'IPV4' && ip.type == 'PUBLIC' 
  end.address
  
  logger.debug "load balancer ip: #{lb_ip}"
  
  node_ips = env.lb_service.load_balancers.find do |lb| 
    lb.name =~ /#{Regexp.escape(lb_name)}/ 
  end.nodes.map do |ip| 
    ip.address 
  end
  
  logger.debug "nodes: #{node_ips}"
  
  {:lb => lb_ip, :nodes => node_ips}
end

def get_test_ip(logger, env)
  test_agent = env.service.servers.find {|server| server.name =~ /test_agent/}.ipv4_address
  logger.info "test agent: #{test_agent}"
  test_agent
end

environment_hash = {
 :atom_hopper => :iad
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
  flavor_type - can either be original or performance
  runner - which runner to use to run the test (jmeter, gatling, etc)
  with_repose - whether repose or origin target server
Usage:
       cloud --name <app name> --test-type <load|duration|benchmark> --action <start|stop>
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
  opt :flavor_type, "Flavor type", :type => :string
  opt :runner, "Runner", :type => :string
  opt :with_repose, "Boolean repose", :type => :boolean
end

Trollop::die :action, "must be specified" unless opts[:action]
Trollop::die :sub_app, "must be specified" unless opts[:sub_app]
Trollop::die :test_type, "must be specified" unless opts[:test_type]
Trollop::die :name, "must be specified" unless opts[:name]

logger.debug opts

if opts[:action] == 'stop'
  #TODO: rm -rf /usr/share/repose
  #TODO: rm -rf /config/*
  #TODO: call stop test 
  
  logger.debug "config: #{config} and logger: #{logger}"
  env = Environment.new(config, logger)
  env.connect(environment_hash[opts[:sub_app].to_sym])
  env.load_balance_connect(environment_hash[opts[:sub_app].to_sym])

  if opts[:flavor_type] == 'performance' 
    if opts[:with_repose]
      #performance with repose!
      logger.debug "we just ran a test on performance flavor with repose"
      server_ip_info = get_server_ips("repose_lb_perf_flavors_withrepose", logger, env)
    else
      #performance without repose!
      logger.debug "we just ran a test on performance flavor without repose"
      server_ip_info = get_server_ips("repose_lb_perf_flavors_withoutrepose", logger, env)
    end
  else
    if opts[:with_repose]
      #original with repose!
      logger.debug "we just ran a test on original flavor with repose"
      server_ip_info = get_server_ips("repose_lb_original_withrepose", logger, env)
    else
      #original with repose!
      logger.debug "we just ran a test on original flavor without repose"
      server_ip_info = get_server_ips("repose_lb_original_withoutrepose", logger, env)
    end
  end

  server_ip_info[:nodes].each do |server|
    logger.info server
    #logger.debug "scp root@#{server}:/home/repose/logs/sysstats.log #{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/#{tmp_dir}/sysstats.log_#{server}"
    #system "scp root@#{server}:/home/repose/logs/sysstats.log #{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/#{tmp_dir}/sysstats.log_#{server}"
    logger.debug "with repose: #{opts[:with_repose]}"
    if opts[:with_repose]
      logger.info "stop jmxtrans"
      system "ssh root@#{server} 'cd /usr/share/jmxtrans ; ./jmxtrans.sh stop '"
      system "ssh root@#{server} 'curl http://localhost:6666 -v'"      
      #logger.debug "copying over from scp root@#{server}:/home/repose/logs/jmxdata.out to #{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/#{tmp_dir}/jmxdata.out"
      #system "scp root@#{server}:/home/repose/logs/jmxdata.out #{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/#{tmp_dir}/jmxdata.out_#{server}"
      
      system "ssh root@#{server} 'rm -rf /home/repose/configs/* '" 
      system "ssh root@#{server} 'rm -rf /home/repose/usr/share/repose/repose-valve.jar '" 
      system "ssh root@#{server} 'rm -rf /home/repose/usr/share/repose/filters/* '" 
      system "ssh root@#{server} 'rm -rf /home/repose/logs/* '" 
    end
    system "ssh root@#{server} -f 'killall node '"
    system "ssh root@#{server} -f 'killall java '"
    system "ssh root@#{server} -f 'killall sar '"
    system "ssh root@#{server} -f 'service sysstat stop '"
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
          guid = test_type["guid"]
        end
      end
    end
  end

  raise ArgumentError, "no guid" unless guid

  test_agent = get_test_ip(logger, env)
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
  
  logger.info "http://localhost/#{opts[:app]}/applications/#{opts[:sub_app]}/#{opts[:test_type]}/stop"
  logger.info request_body.to_json
  response = RestClient.post "http://localhost/#{opts[:app]}/applications/#{opts[:sub_app]}/#{opts[:test_type]}/stop", request_body.to_json
  logger.debug response
  logger.debug response.code
   FileUtils.rm_rf(File.expand_path("test_execution.yaml", Dir.pwd))

  Net::SSH.start(test_agent, 'root') do |ssh|
    ssh.exec!("/home/apache/apache-jmeter-2.10/bin/shutdown.sh")
    ssh.exec!("sleep 5")
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
  env = Environment.new(config, logger)
  env.connect(environment_hash[opts[:sub_app].to_sym])
  env.load_balance_connect(environment_hash[opts[:sub_app].to_sym])
  
  if opts[:flavor_type] == 'performance' 
    if opts[:with_repose]
      #performance with repose!
      logger.debug "we are setting up a test on performance flavor with repose"
      server_ip_info = get_server_ips("repose_lb_perf_flavors_withrepose", logger, env)
    else
      #performance without repose!
      logger.debug "we are setting up a test on performance flavor without repose"
      server_ip_info = get_server_ips("repose_lb_perf_flavors_withoutrepose", logger, env)
    end
  else
    if opts[:with_repose]
      #original with repose!
      logger.debug "we are setting up a test on original flavor with repose"
      server_ip_info = get_server_ips("repose_lb_original_withrepose", logger, env)
    else
      #original with repose!
      logger.debug "we are setting up a test on original flavor without repose"
      server_ip_info = get_server_ips("repose_lb_original_withoutrepose", logger, env)
    end
  end

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
    system "cd ~/repose_repo/repose ; git pull origin master; mvn clean install -DskipTests; "
  end

  server_ip_info[:nodes].each do |server|

    config_list.each do |config_data|
      #first, download from remote

      if config['storage_info']['destination'] == 'localhost'
        logger.info "moving over: #{JSON.parse(config_data)['name']}"
        if JSON.parse(config_data)['name'] == 'system-model.cfg.xml'
          system_model_contents = SystemModelTemplate.new(server_ip_info[:nodes],File.read("#{config['storage_info']['path']}/#{JSON.parse(config_data)['location']}")).render

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
          system_model_contents = SystemModelTemplate.new(server_ip_info[:nodes],File.read("#{config['storage_info']['path']}/#{JSON.parse(config_data)['location']}")).render

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
  
    logger.info "download repose"
    if opts[:with_repose]

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
        system "ssh root@#{server} 'cd /usr/share/jmxtrans ; ./jmxtrans.sh stop '"
        logger.debug "start jmxtrans"
        system "ssh root@#{server} -f 'cd /usr/share/jmxtrans ; ./jmxtrans.sh start #{plugin['name']} '" 
      end

      if opts[:release]
        if opts[:release] == 'master'
          logger.info "download master version"
          
          filter_bundle_ear = Dir.glob("/root/repose_repo/repose/repose-aggregator/components/filter-bundle/target/*.ear").first
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
        system "ssh root@#{server} -f 'node /home/mocks/#{name} & '"
      end 
      secondary_responders.each do |key, responder|
        responder_json = JSON.parse(responder)
        name = responder_json['name']
        location = responder_json['location']
        if config['storage_info']['destination'] == 'localhost'
          Net::SSH.start(server, 'root') do |ssh|
            ssh.exec!("mkdir -p /home/mocks")
          end
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
        
        system "ssh root@#{server} -f 'node /home/mocks/#{name} & '"
      end if secondary_responders

      logger.info "start logging sysstats"
      system "ssh root@#{server} -f 'sar -o /home/repose/logs/sysstats.log 30 >/dev/null 2>&1 & '"

      logger.info "start repose"
      system "ssh root@#{server} -f 'nohup java -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -jar /home/repose/usr/share/repose/repose-valve.jar -c /home/repose/configs/ -s 6666 start & '" 
       
      
      is_valid = false
      until is_valid
        begin
          response = Net::HTTP.get_response(URI("http://#{server}:7070"))
          logger.info "response: #{response}"
          response_code = response.code
          logger.info "response: #{response_code}"
          is_valid = response_code.to_i < 500
        rescue Exception => msg
          logger.info "response: #{response}"
          if response
            response_code = response.code
            logger.info "response: #{response_code}"
            is_valid = response_code.to_i < 500
          end
          logger.info "connection exception: #{msg}"
        end
        sleep 1
      end
    end
  end

  test_agent = get_test_ip(logger, env)
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
  duration = test_data["duration"]
  case opts[:test_type]
    when "load"
      rampdown = test_data["rampdown"] 
      throughput = test_data["throughput"]
      logger.info "ssh root@#{test_agent} -f 'nohup /home/apache/apache-jmeter-2.10/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.10/bin/jmeter.properties -Jhost=#{host} -Jstartdelay=#{startdelay} -Jrampup=#{rampup} -Jduration=#{duration} -Jrampdown=#{rampdown} -Jthroughput=#{throughput} -Jport=80 >> /home/apache/test/summary.log & '"
      system "ssh root@#{test_agent} -f 'nohup /home/apache/apache-jmeter-2.10/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.10/bin/jmeter.properties -Jhost=#{host} -Jstartdelay=#{startdelay} -Jrampup=#{rampup} -Jduration=#{duration} -Jrampdown=#{rampdown} -Jthroughput=#{throughput} -Jport=80 >> /home/apache/test/summary.log & '"
    when "stress"  
      rampup_threads = test_data["rampup_threads"]  
      maxthreads = test_data["maxthreads"]
      system "ssh root@#{test_agent} -f 'nohup /home/apache/apache-jmeter-2.10/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.10/bin/jmeter.properties -Jhost=#{host} -Jstartdelay=#{startdelay} -Jrampup=#{rampup} -Jduration=#{duration} -Jrampup_threads=#{rampup_threads} -Jmaxthreads=#{maxthreads} -Jport=80 >> /home/apache/test/summary.log & '"
    else
      raise ArgumentError, "invalid test type"
    end
  request_body = {"length" =>  opts[:length], "name" => opts[:name], "runner" => opts[:runner] }
  request_body["description"] = opts[:description] if opts[:description]
  request_body["flavor_type"] = opts[:flavor_type] if opts[:flavor_type]
  request_body["release"] = opts[:release] if opts[:release]
  
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
          raise ArgumentError, "already exists!"
        else
          sub_app_name["test_type"] << {
            "name" => opts[:test_type],
            "guid" => JSON.parse(response)["guid"]
          }
        end
      else
        app_name["sub_app"] << {
          "name" => opts[:sub_app],
          "test_type" => [{
            "name" => opts[:test_type],
            "guid" => JSON.parse(response)["guid"]
          }]
        }
      end
    else
      test_yaml << {
        "name" => opts[:app],
        "sub_app" => [{
          "name" => opts[:sub_app],
          "test_type" => [{
            "name" => opts[:test_type],
            "guid" => JSON.parse(response)["guid"]
          }]
        }]
      }
    end
  else
    test_yaml = [{
      "name" => opts[:app],
      "sub_app" => [{
        "name" => opts[:sub_app],
        "test_type" => [{
          "name" => opts[:test_type],
          "guid" => JSON.parse(response)["guid"]
        }]
      }]
    }]
  end

  logger.info "yaml content: #{test_yaml.to_yaml}"

  File.open(File.expand_path("test_execution.yaml", Dir.pwd), 'w') {|f| f.write test_yaml.to_yaml }
end
