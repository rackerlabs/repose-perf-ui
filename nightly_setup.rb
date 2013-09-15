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

config = YAML.load_file("#{Dir.pwd}/config/config.yaml")
logger.debug "configuration file: #{config}"

opts = Trollop::options do
  version "fog wrapper for repose pt 0.0.1 - 2013 Dimitry Ushakov"
  banner <<-EOS
Responsible for spinning up vm's with repose and tests.  Tightly couple to the machine it's running on as it's utilizing specific directories.  Linux only.
Usage:
       cloud --name <app name> --test-type <load|duration|benchmark> --action <start|stop>
where [options] are:
EOS
  opt :app, "App name", :type => :string
  opt :test_type, "Test type", :default => "load"
  opt :action, "Action", :type => :string
  opt :length, "Length in minutes", :type => :int
  opt :tag, "Test tag", :type => :string
  opt :release, "Specify Release", :type => :string
  opt :id, "Tag id", :type => :string
  opt :with_repose, "Optional repose-specific parameter, used to specify whether to deploy repose or not", :type => :boolean
end

Trollop::die :action, "must be specified" unless opts[:action]
Trollop::die :app, "must be specified" unless opts[:app]
Trollop::die :test_type, "must be specified" unless opts[:test_type]
logger.debug opts

logger.debug "start shell"
system "ssh-agent -c"
logger.debug "shell started"

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
  env.connect(:dfw)
  env.load_balance_connect(:dfw)
  env.servers.select {|server| server.state == 'ACTIVE' && server.name =~ /#{Regexp.escape(opts[:app])}/}.each do |server|
    logger.debug server
    system "scp root@#{server.ipv4_address}:/home/repose/logs/sysstats.log #{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/#{tmp_dir}/sysstats.log_#{server.name}"
    logger.debug opts[:with_repose]
    if opts[:with_repose]
      system "ssh root@#{server.ipv4_address} 'cd /usr/share/jmxtrans ; ./jmxtrans.sh stop '"
      system "ssh root@#{server.ipv4_address} 'curl http://localhost:6666 -v'"      
      logger.debug "copying over to #{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/#{tmp_dir}/jmxdata.out"
      system "scp root@#{server.ipv4_address}:/home/repose/logs/jmxdata.out #{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/#{tmp_dir}/jmxdata.out_#{server.name}"
      
      system "ssh root@#{server.ipv4_address} 'rm -rf /home/repose/configs/* '" 
      system "ssh root@#{server.ipv4_address} 'rm -rf /home/repose/usr/share/repose/repose-valve.jar '" 
      system "ssh root@#{server.ipv4_address} 'rm -rf /home/repose/usr/share/repose/filters/* '" 
      system "ssh root@#{server.ipv4_address} 'rm -rf /home/repose/logs/* '" 
    end
    system "ssh root@#{server.ipv4_address} -f 'killall node '"
    system "ssh root@#{server.ipv4_address} -f 'killall sar '"
    system "ssh root@#{server.ipv4_address} -f 'service sysstat stop '"
  end
  unless opts[:with_repose]
    env.tear_down "#{opts[:app]}"
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
  env.connect(:dfw)
  env.load_balance_connect(:dfw)

  if env.servers.find_all {|server| server.name =~ /#{Regexp.escape(opts[:app])}/}.empty?
    env.spin_up_servers(node_count, "#{opts[:app]}", "4GB")
  end

  nodes = env.servers.find_all {|server| server.name =~ /#{Regexp.escape(opts[:app])}/}.map {|server| {:id => server.id, :address => server.ipv4_address}}

  logger.debug "Nodes: #{nodes}"

  #modify system-model and dd xmls and stage all configs. 
  system_model_contents = SystemModelTemplate.new(nodes,File.read("#{config_target_dir}/system-model.cfg.xml")).render
  File.open("#{config_target_dir}/system-model.cfg.xml", 'w') { |f| f.write(system_model_contents) }

  #load configs
  #download repose and spin up
  #load and spin up auth and mock responders

  env.servers.select {|server| server.state == 'ACTIVE' && server.name =~ /#{Regexp.escape(opts[:app])}/ }.each do |server|
    Dir.glob("#{config_target_dir}/**") do |file| 
      logger.debug "is #{file} a directory: #{File.directory?(file)}"
      server.scp file, "/home/repose/configs/", {:recursive => true}
    end

    server.scp "#{target_dir}/auth_responder.js", "/home/mocks/auth_responder/server.js"
    server.scp "#{target_dir}/mock_responder.js", "/home/mocks/mock_responder/server.js"
    server.scp "#{source_dir}/jmxparams.json","/usr/share/jmxtrans/example.json"

    logger.info "everything is uploaded"
    system "ssh root@#{server.ipv4_address} -f 'nohup node /home/mocks/auth_responder/server.js & '" 
    logger.info "started auth on #{server.ipv4_address}"
    system "ssh root@#{server.ipv4_address} -f 'nohup node /home/mocks/mock_responder/server.js & '" 
    logger.info "started mock on #{server.ipv4_address}"
    #download repose
    if opts[:with_repose]
      unless opts[:release].empty?
        system "ssh root@#{server.ipv4_address} 'cd /home/repose ; virtualenv . ; source bin/activate ; pip install requests ; pip install narwhal ; download-repose --version #{opts[:release]}'" 
      else
        system "ssh root@#{server.ipv4_address} 'cd /home/repose ; virtualenv . ; source bin/activate ; pip install requests ; pip install narwhal ; download-repose --snapshot'"       
      end
      logger.debug "stop jmxtrans"
      system "ssh root@#{server.ipv4_address} 'cd /usr/share/jmxtrans ; ./jmxtrans.sh stop '"
      logger.debug "start jmxtrans"
      system "ssh root@#{server.ipv4_address} -f 'cd /usr/share/jmxtrans ; ./jmxtrans.sh start example.json '" 
      #start repose
      logger.debug "start repose"
      system "ssh root@#{server.ipv4_address} -f 'nohup java -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -jar /home/repose/usr/share/repose/repose-valve.jar -c /home/repose/configs/ -s 6666 start & '" 
    end
    logger.debug "start logging"
    system "ssh root@#{server.ipv4_address} -f 'sar -o /home/repose/logs/sysstats.log 30 >/dev/null 2>&1 & '"
  end
  length = opts[:length] ? opts[:length].to_i : 60

  start_time = 1000 * (Time.now.to_i + (5 * 60))
  logger.debug "start time: #{start_time}"
  end_time = start_time + (length * 60 * 1000)
  logger.debug "end time: #{end_time}"
  logger.debug "tag: #{opts[:tag]}"
  test_json_contents = TestTemplate.new(start_time, end_time, opts[:tag], opts[:id], File.read("#{target_dir}/#{opts[:test_type]}_test.json")).render
  File.open("#{target_dir}/load_test.json", 'w') { |f| f.write(test_json_contents) }
  logger.debug test_json_contents
  logger.debug "took care of test json content"

  lb = env.load_balance_connect :dfw
  logger.debug "load balancer #{lb}"

  if opts[:with_repose]
    lb_ip = env.lb_service.load_balancers.find { |lb| lb.name =~ /#{Regexp.escape(opts[:app])}_withrepose/ }.virtual_ips.find {|ip| ip.ip_version == 'IPV4' && ip.type == 'PUBLIC' }.address
  else
    lb_ip = env.lb_service.load_balancers.find { |lb| lb.name =~ /#{Regexp.escape(opts[:app])}_withoutrepose/ }.virtual_ips.find {|ip| ip.ip_version == 'IPV4' && ip.type == 'PUBLIC' }.address
  end
  logger.debug "load balance ip address: #{lb_ip}"

  jmeter_contents = JmeterTemplate.new(start_time, end_time, 20, 60, lb_ip, File.read("#{target_dir}/test_#{opts[:app]}.jmx")).render
  logger.debug jmeter_contents 
  File.open("#{target_dir}/test_#{opts[:app]}.jmx", 'w') { |f| f.write(jmeter_contents) }
  #start tiem and stop time should both be in millis starting at 5 minutes AFTER spinup of all servers and scp'ing all files
  #modify runner file (ip, threads, start, stop, rampup) and stage 
  logger.debug "took care of jmeter json content"

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
  system "/root/apache-jmeter-2.9/bin/jmeter -n -t #{target_dir}/test_#{opts[:app]}.jmx -p /root/apache-jmeter-2.9/bin/load_test.properties >> #{config['home_dir']}/files/apps/#{opts[:app]}/results/#{opts[:test_type]}/current/summary.log" 
end

logger.debug "stop shell"
system "killall ssh-agent"
logger.debug "shell stopped"
