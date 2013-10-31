#!/usr/bin/env ruby

require 'fog'
require_relative './Models/environment.rb'
require_relative './Models/template.rb'
require 'trollop'
require 'json'
require 'nokogiri'
require 'erb'
require 'logging'
require 'rbconfig'
require 'yaml'

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

opts = Trollop::options do
  version "fog wrapper for repose pt 0.0.1 - 2013 Dimitry Ushakov"
  banner <<-EOS
Responsible for spinning up vm's with repose and tests.  Tightly couple to the machine it's running on as it's utilizing specific directories.  Linux only.
Attributes:
  app - this is an application name.  For our purposes it's either passthrough, all_filters, rbac, rl_dds
  test_type - can either be load or benchmark (will either run jmeter or auto-bench)
  action - either start or stop
  length - load test length in minutes
  tag - description of the test
  release - specify release.  We'll be testing against 2.11.0
  id - specific jenkins tag id.  has to be unique
  with_repose - to test with repose or directly against origin
  flavor_type - can either be original or performance
Usage:
       cloud --name <app name> --test-type <load|duration|benchmark> --action <start|stop>
where [options] are:
EOS
  opt :app, "App name", :type => :string
  opt :test_type, "Test type", :default => "load"
  opt :action, "Action", :type => :string
  opt :length, "Length in minutes", :type => :int
  opt :tag, "Test tag", :type => :string
  opt :release, "Specify Release", :default => ""
  opt :id, "Tag id", :type => :string
  opt :with_repose, "Optional repose-specific parameter, used to specify whether to deploy repose or not", :default => false
  opt :flavor_type, "Flavor type", :type => :string
end

Trollop::die :action, "must be specified" unless opts[:action]
Trollop::die :app, "must be specified" unless opts[:app]
Trollop::die :test_type, "must be specified" unless opts[:test_type]
logger.debug opts

logger.debug "start shell"
system "ssh-agent -s"
ssh_agent_id = $?.pid
logger.debug "shell started in pid #{ssh_agent_id}"

tmp_dir = "tmp_#{DateTime.now.strftime('%Y%m%dT%H%M%S')}"
logger.debug "temp directory: #{tmp_dir}"

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
  raise ArgumentError, "Test already running" if Dir.exists?("#{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/current")
  #setup directories
  source_dir = "#{config['home_dir']}/files/apps/#{opts[:app]}/tests/setup/main/"
  logger.debug "source directory: #{source_dir}"
  target_dir = "#{config['home_dir']}/files/apps/#{opts[:app]}/tests/setup/#{tmp_dir}"
  logger.debug "target directory: #{target_dir}"
  logger.debug "create target directory and copy everything in source directory to target"

  raise ArgumentError, "source directory does not exist" unless Dir.exists?(source_dir)
  Dir.mkdir(target_dir)
  FileUtils.cp_r(Dir["#{source_dir}*"],target_dir)

  config_source_dir = "#{config['home_dir']}/files/apps/#{opts[:app]}/configs/main/"
  logger.debug "configuration source directory: #{config_source_dir}"
  config_target_dir = "#{config['home_dir']}/files/apps/#{opts[:app]}/configs/#{tmp_dir}"
  logger.debug "configuration target directory: #{config_target_dir}"

  logger.debug "create configuration target directory and copy everything from source to target"
  Dir.mkdir(config_target_dir)
  FileUtils.cp_r(Dir["#{config_source_dir}*"],config_target_dir)

  test_json = JSON.parse(File.read("#{target_dir}/#{opts[:test_type]}_test.json"))
  logger.debug "test json: #{test_json}"
  runner_json = JSON.parse(File.read("#{target_dir}/#{opts[:test_type]}_test_#{test_json['runner']}.json"))
  logger.debug "runner json: #{runner_json}"

  #find out how many <node> values there are.  Create that many target servers
  node_count = test_json["node_count"]
  logger.debug "number of nodes: #{node_count}"

  #spin up target servers.  save ip's.  spin up lb and save ip
  logger.debug "config: #{config} and logger: #{logger}"
  env = Environment.new(config, logger)
  env.connect(:iad)
  env.load_balance_connect(:iad)
  
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

  logger.debug "Nodes: #{server_ip_info[:nodes]}"

  #modify system-model and dd xmls and stage all configs. 
  system_model_contents = SystemModelTemplate.new(server_ip_info[:nodes],File.read("#{config_target_dir}/system-model.cfg.xml")).render
  File.open("#{config_target_dir}/system-model.cfg.xml", 'w') { |f| f.write(system_model_contents) }

  #load configs
  #download repose and spin up
  #load and spin up auth and mock responders

  server_ip_info[:nodes].each do |server|
    logger.debug "set up strick host checking"
    #system "ssh -o 'StrictHostKeyChecking no' #{server} uptime"
    Dir.glob("#{config_target_dir}/**") do |file| 
      logger.debug "is #{file} a directory: #{File.directory?(file)}"
      logger.debug "copy files over with this command: scp -r #{file} root@#{server}:/home/repose/configs/"
      system "scp -r #{file} root@#{server}:/home/repose/configs/"
    end

    system "scp #{target_dir}/auth_responder.js root@#{server}:/home/mocks/auth_responder/server.js"
    system "scp #{target_dir}/mock_responder.js root@#{server}:/home/mocks/mock_responder/server.js"
    system "scp #{source_dir}/jmxparams.json root@#{server}:/usr/share/jmxtrans/example.json"

    logger.info "everything is uploaded"
    system "ssh root@#{server} -f 'nohup node /home/mocks/auth_responder/server.js & '" 
    logger.info "started auth on #{server}"
    system "ssh root@#{server} -f 'nohup node /home/mocks/mock_responder/server.js & '" 
    logger.info "started mock on #{server}"
    #download repose
    if opts[:with_repose]
      unless opts[:release].empty?
        system "ssh root@#{server} 'cd /home/repose ; virtualenv . ; source bin/activate ; pip install requests ; pip install narwhal ; download-repose --version #{opts[:release]}'" 
      else
        system "ssh root@#{server} 'cd /home/repose ; virtualenv . ; source bin/activate ; pip install requests ; pip install narwhal ; download-repose --snapshot'"       
      end
      logger.debug "stop jmxtrans"
      system "ssh root@#{server} 'cd /usr/share/jmxtrans ; ./jmxtrans.sh stop '"
      logger.debug "start jmxtrans"
      system "ssh root@#{server} -f 'cd /usr/share/jmxtrans ; ./jmxtrans.sh start example.json '" 
      #start repose
      logger.debug "start repose"
      system "ssh root@#{server} -f 'nohup java -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -jar /home/repose/usr/share/repose/repose-valve.jar -c /home/repose/configs/ -s 6666 start & '" 
    end
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
  File.open("#{target_dir}/load_test.json", 'w') { |f| f.write(test_json_contents) }
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
    logger.debug "time now: #{Time.now.to_i}.  waiting until #{end_time}"
    sleep(30)
  end
  system "scp root@#{test_agent}:/home/apache/summary.log #{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/current/summary.log"
  system "ssh root@#{test_agent} 'rm /home/apache/summary.log '"  
end

logger.debug "stop shell"
system "kill -9 #{ssh_agent_id}"
logger.debug "shell stopped"
