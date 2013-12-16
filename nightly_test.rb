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
  begin
    logger.debug "copy directories over"
    #copy directory over.  remove current
    raise ArgumentError, "current directory does not exist" unless Dir.exists?("#{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/current") 
    raise ArgumentError, "temp directory already exists"  if Dir.exists?("#{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/#{tmp_dir}") 
    FileUtils.cp_r(
      "#{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/current/." , 
      "#{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/#{tmp_dir}")
    logger.debug "remove directories"
    FileUtils.rm_r("#{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/current")
  rescue ArgumentError => e
    logger.error e.message
  end

  logger.debug "config: #{config} and logger: #{logger}"
  env = Environment.new(config, logger)
  env.connect(:iad)
  env.load_balance_connect(:iad)
  logger.debug "connected to iad.  Now need to move the data over"
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
    logger.debug server
    logger.debug "scp root@#{server}:/home/repose/logs/sysstats.log #{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/#{tmp_dir}/sysstats.log_#{server}"
    system "scp root@#{server}:/home/repose/logs/sysstats.log #{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/#{tmp_dir}/sysstats.log_#{server}"
    logger.debug "with repose: #{opts[:with_repose]}"
    if opts[:with_repose]
      system "ssh root@#{server} 'cd /usr/share/jmxtrans ; ./jmxtrans.sh stop '"
      system "ssh root@#{server} 'curl http://localhost:6666 -v'"      
      logger.debug "copying over from scp root@#{server}:/home/repose/logs/jmxdata.out to #{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/#{tmp_dir}/jmxdata.out"
      system "scp root@#{server}:/home/repose/logs/jmxdata.out #{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/#{tmp_dir}/jmxdata.out_#{server}"
      
      system "ssh root@#{server} 'rm -rf /home/repose/configs/* '" 
      system "ssh root@#{server} 'rm -rf /home/repose/usr/share/repose/repose-valve.jar '" 
      system "ssh root@#{server} 'rm -rf /home/repose/usr/share/repose/filters/* '" 
      system "ssh root@#{server} 'rm -rf /home/repose/logs/* '" 
    end
    system "ssh root@#{server} -f 'killall node '"
    system "ssh root@#{server} -f 'killall sar '"
    system "ssh root@#{server} -f 'service sysstat stop '"
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
  
  if opts[:with_repose] and opts[:release] and opts[:release] == 'master'
    system "cd ~/repose_repo/repose ; git pull origin master; mvn clean install -DskipTests; "
  end
  
  logger.info "get meta information"
  meta_information = redis.hgetall("#{opts[:app]}:#{opts[:sub_app]}:setup:meta")
  main_responders = main_information.find_all {|m| m =~ /responder\|main\|/}
  secondary_responders = main_information.find_all {|m| m =~ /responder\|secondary\|/}
  logger.info "main responders: #{main_responders}"
  logger.info "secondary responders: #{secondary_responders}"


  server_ip_info[:nodes].each do |server|
    config_list.each do |config_data|
      #first, download from remote

      if config['storage_info']['destination'] == 'localhost'
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
      logger.info "stop jmxtrans"
      system "ssh root@#{server} 'cd /usr/share/jmxtrans ; ./jmxtrans.sh stop '"
      logger.debug "start jmxtrans"
      system "ssh root@#{server} -f 'cd /usr/share/jmxtrans ; ./jmxtrans.sh start example.json '" 
      logger.info "start repose"
      system "ssh root@#{server} -f 'nohup java -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -jar /home/repose/usr/share/repose/repose-valve.jar -c /home/repose/configs/ -s 6666 start & '" 
      
      logger.info "upload responders"
      
      #TODO: upload responders
      #TODO: start responders
      #TODO: test if localhost:7070 returns correct non-500
    end
  end

  #TODO: upload jmeter stuff (based on runner) such as jmx
  #TODO: make a call on test agent
  #TODO: make a post call to post the data to start the test
end
=begin

  test_json = JSON.parse(File.read("#{target_dir}/#{opts[:test_type]}_test.json"))
  logger.debug "test json: #{test_json}"
  runner_json = JSON.parse(File.read("#{target_dir}/#{opts[:test_type]}_test_#{test_json['runner']}.json"))
  logger.debug "runner json: #{runner_json}"

  #find out how many <node> values there are.  Create that many target servers
  node_count = test_json["node_count"]
  logger.debug "number of nodes: #{node_count}"


  server_ip_info[:nodes].each do |server|
    logger.debug "set up strick host checking"
    #system "ssh -o 'StrictHostKeyChecking no' #{server} uptime"

    system "scp #{target_dir}/auth_responder.js root@#{server}:/home/mocks/auth_responder/server.js"
    system "scp #{target_dir}/mock_responder.js root@#{server}:/home/mocks/mock_responder/server.js"
    system "scp #{source_dir}/jmxparams.json root@#{server}:/usr/share/jmxtrans/example.json"

    logger.info "everything is uploaded"
    system "ssh root@#{server} -f 'nohup node /home/mocks/auth_responder/server.js & '" 
    logger.info "started auth on #{server}"
    system "ssh root@#{server} -f 'nohup node /home/mocks/mock_responder/server.js & '" 
    logger.info "started mock on #{server}"

    logger.debug "start logging"
    system "ssh root@#{server} -f 'sar -o /home/repose/logs/sysstats.log 30 >/dev/null 2>&1 & '"
  end
  length = opts[:length] ? opts[:length].to_i : 60

  start_time = 1000 * (Time.now.to_i + (2 * 60))
  logger.debug "start time: #{start_time}"
  end_time = start_time + (length * 60 * 1000)
  logger.debug "end time: #{end_time}"
  logger.debug "tag: #{opts[:tag]}"
  test_type_template = opts[:with_repose] ? "repose_test" : "origin_test"
  test_json_contents = TestTemplate.new(start_time, end_time, opts[:tag], opts[:id], opts[:test_type], File.read("#{target_dir}/#{opts[:test_type]}_test.json")).render
  File.open("#{target_dir}/#{opts[:test_type]}_test.json", 'w') { |f| f.write(test_json_contents) }
  logger.debug test_json_contents
  logger.debug "took care of test json content"

  lb_ip = server_ip_info[:lb]
  logger.debug "load balance ip address: #{lb_ip}"

  #jmeter_contents = JmeterTemplate.new(start_time, end_time, 20, 60, lb_ip, File.read("#{target_dir}/test_#{opts[:app]}.jmx")).render
  #logger.debug jmeter_contents 
  #File.open("#{target_dir}/test_#{opts[:app]}.jmx", 'w') { |f| f.write(jmeter_contents) }
  #start tiem and stop time should both be in millis starting at 5 minutes AFTER spinup of all servers and scp'ing all files
  #modify runner file (ip, threads, start, stop, rampup) and stage 
  #logger.debug "took care of jmeter json content"

  #make results directory
  Dir.mkdir("#{config['home_dir']}/files/apps/#{opts[:app]}/results") unless Dir.exists?("#{config['home_dir']}/files/apps/#{opts[:app]}/results")
  Dir.mkdir("#{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}") unless Dir.exists?("#{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}")
  Dir.mkdir("#{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/current")

  #copy over configs and test setup
  Dir.mkdir("#{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/current/meta")
  Dir.mkdir("#{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/current/configs")
  FileUtils.cp_r("#{target_dir}/." , "#{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/current/meta")
  FileUtils.cp_r("#{config_target_dir}/." , "#{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/current/configs")

  #start test
  test_agent = env.service.servers.find {|server| server.name =~ /test_agent/}.ipv4_address
  logger.debug "test agent: #{test_agent}"

  system "scp #{target_dir}/test_#{opts[:app]}.jmx root@#{test_agent}:/home/apache/test.jmx"  
  system "ssh root@#{test_agent} -f 'nohup /home/apache/apache-jmeter-2.10/bin/jmeter -n -t /home/apache/test.jmx -p /home/apache/apache-jmeter-2.10/bin/jmeter.properties -Jhost=#{lb_ip} -Jthreads=#{runner_json['threads']} -Jramp=#{runner_json['rampup']} -Jport=80 -Jduration=#{length * 60 * 1000} >> /home/apache/summary.log & '"
  
  until Time.now.to_i * 1000 >= end_time
    logger.debug "time now: #{Time.now.to_i}000.  waiting until #{end_time}"
    sleep(30)
  end
  system "scp root@#{test_agent}:/home/apache/summary.log #{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/current/summary.log"
  system "ssh root@#{test_agent} -f '/home/apache/apache-jmeter-2.10/bin/shutdown.sh ; sleep 10 '"
  system "ssh root@#{test_agent} 'rm /home/apache/summary.log '"  
=end
