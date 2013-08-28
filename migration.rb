#!/usr/bin/env ruby

require 'fog'
require '/root/repose/dist/Models/environment.rb'
require 'trollop'
require 'json'
require 'nokogiri'
require 'erb'

class Template
  attr_accessor :template

  def render
    ERB.new(@template).result(binding)
  end
end

class SystemModelTemplate < Template
  attr_reader :nodes

  def initialize(nodes, template)
    @nodes = nodes
    @template = template
  end
end

class TestTemplate < Template
  attr_reader :start_time, :stop_time, :tag

  def initialize(start_time, end_time, tag, id, template)
    @start_time = start_time
    @stop_time = end_time
    @template = template
    @tag = tag
    @id = id
  end
end

class JmeterTemplate < Template
  attr_reader :start_time, :end_time, :threads, :ramp_time, :host

  def initialize(start_time, end_time, threads, ramp_time, host, template)
    @start_time = start_time
    @end_time = end_time
    @threads = threads
    @ramp_time = ramp_time
    @host = host
    @template = template
  end
end


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
Trollop::die :app, "app must be specified if action is start" unless (opts[:action] == 'start' && opts[:app]) || opts[:action] == 'stop'
p opts

p "start shell"
system "ssh-agent -c"
p "shell started"

tmp_dir = "tmp_#{DateTime.now.strftime('%Y%m%dT%H%M%S')}"

if opts[:action] == 'stop'
  p "copy directories over"
  #copy directory over.  remove current
  FileUtils.cp_r("/root/repose/dist/files/apps/#{opts[:app]}/results/adhoc/current/." , "/root/repose/dist/files/apps/#{opts[:app]}/results/adhoc/#{tmp_dir}")
  FileUtils.rm_r("/root/repose/dist/files/apps/#{opts[:app]}/results/adhoc/current")
  env = Environment.new
  env.connect(:dfw)
  env.servers.select {|server| server.state == 'ACTIVE' }.each do |server|
    p server
    p opts[:with_repose]
    if opts[:with_repose]
      system "ssh root@#{server.ipv4_address} 'cd /usr/share/jmxtrans ; ./jmxtrans.sh stop '"
      system "ssh root@#{server.ipv4_address} 'curl http://localhost:6666 -v'"      
      p "copying over to /root/repose/dist/files/apps/#{opts[:app]}/results/adhoc/#{tmp_dir}/jmxdata.out"
      system "scp root@#{server.ipv4_address}:/home/repose/logs/jmxdata.out /root/repose/dist/files/apps/#{opts[:app]}/results/adhoc/#{tmp_dir}/jmxdata.out_#{server.name}"
      
      system "ssh root@#{server.ipv4_address} 'rm -rf /home/repose/configs/* '" 
      system "ssh root@#{server.ipv4_address} 'rm -rf /home/repose/usr/share/repose/repose-valve.jar '" 
      system "ssh root@#{server.ipv4_address} 'rm -rf /home/repose/usr/share/repose/filters/* '" 
      system "ssh root@#{server.ipv4_address} 'rm -rf /home/repose/logs/* '" 
    end
    system "ssh root@#{server.ipv4_address} -f 'killall node '"
  end
elsif opts[:action] == 'start'
  unless Dir.exists?("/root/repose/dist/files/apps/#{opts[:app]}/results/adhoc/current")

    #setup directories
    source_dir = "/root/repose/dist/files/apps/#{opts[:app]}/tests/setup/main/"
    target_dir = "/root/repose/dist/files/apps/#{opts[:app]}/tests/setup/#{tmp_dir}"
    Dir.mkdir(target_dir)
    FileUtils.cp_r(Dir["#{source_dir}*"],target_dir)

    config_source_dir = "/root/repose/dist/files/apps/#{opts[:app]}/configs/main/"
    config_target_dir = "/root/repose/dist/files/apps/#{opts[:app]}/configs/#{tmp_dir}"
    Dir.mkdir(config_target_dir)
    FileUtils.cp_r(Dir["#{config_source_dir}*"],config_target_dir)

    test_json = JSON.parse(File.read("#{target_dir}/#{opts[:test_type]}_test.json"))
    runner_json = JSON.parse(File.read("#{target_dir}/#{opts[:test_type]}_test_#{test_json['runner']}.json"))

    #find out how many <node> values there are.  Create that many target servers
    node_count = test_json["node_count"]

    #spin up target servers.  save ip's.  spin up lb and save ip
    env = Environment.new
    env.connect(:dfw)
  

    nodes = env.servers.map {|server| {:id => server.id, :address => server.ipv4_address} if server.name =~ /test/ }

    #modify system-model and dd xmls and stage all configs. 
    system_model_contents = SystemModelTemplate.new(nodes,File.read("#{config_target_dir}/system-model.cfg.xml")).render
    File.open("#{config_target_dir}/system-model.cfg.xml", 'w') { |f| f.write(system_model_contents) }

    #load configs
    #download repose and spin up
    #load and spin up auth and mock responders

    env.servers.select {|server| server.state == 'ACTIVE' && server.name =~ /test/ }.each do |server|
      Dir.glob("#{config_target_dir}/**"){ |file| p "#{config_target_dir}/#{file}"; p File.directory?(file); server.scp file, "/home/repose/configs/", {:recursive => true}}
      server.scp "#{target_dir}/auth_responder.js", "/home/mocks/auth_responder/server.js"
      server.scp "#{target_dir}/mock_responder.js", "/home/mocks/mock_responder/server.js"
      server.scp "#{source_dir}/jmxparams.json","/usr/share/jmxtrans/example.json"
      p "everything is uploaded"
      system "ssh root@#{server.ipv4_address} -f 'nohup node /home/mocks/auth_responder/server.js & '" 
      p "started auth on #{server.ipv4_address}"
      system "ssh root@#{server.ipv4_address} -f 'nohup node /home/mocks/mock_responder/server.js & '" 
      p "started mock on #{server.ipv4_address}"
      #download repose
      if opts[:with_repose]
        unless opts[:release].empty?
          system "ssh root@#{server.ipv4_address} 'cd /home/repose ; virtualenv . ; source bin/activate ; pip install requests ; pip install narwhal ; download-repose --version #{opts[:release]}'" 
        else
          server.scp "project-set/core/valve/target/repose-valve.jar", "/home/repose/usr/share/repose/"
          Dir.glob("/home/jenkins/.m2/repository/com/rackspace/papi/components/extensions/extensions-filter-bundle/*-SNAPSHOT/*.ear") { |file| server.scp file, "/home/repose/usr/share/repose/filters/extensions-filter-bundle.ear"}
          Dir.glob("/home/jenkins/.m2/repository/com/rackspace/papi/components/filter-bundle/*-SNAPSHOT/*.ear") { |file| server.scp file, "/home/repose/usr/share/repose/filters/filter-bundle.ear"}
        end
        p "stop jmxtrans"
        system "ssh root@#{server.ipv4_address} 'cd /usr/share/jmxtrans ; ./jmxtrans.sh stop '"
        p "start jmxtrans"
        system "ssh root@#{server.ipv4_address} -f 'cd /usr/share/jmxtrans ; ./jmxtrans.sh start example.json '" 
        #start repose
        p "start repose"
        system "ssh root@#{server.ipv4_address} -f 'nohup java -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -jar /home/repose/usr/share/repose/repose-valve.jar -c /home/repose/configs/ -s 6666 start & '" 
      end
    end
    length = opts[:length] ? opts[:length].to_i : 60

    start_time = 1000 * (Time.now.to_i + (5 * 60))
    p "start time: #{start_time}"
    end_time = start_time + (length * 60 * 1000)
    p "end time: #{end_time}"
    p "tag: #{opts[:tag]}"
    test_json_contents = TestTemplate.new(start_time, end_time, opts[:tag], opts[:id], File.read("#{target_dir}/#{opts[:test_type]}_test.json")).render
    File.open("#{target_dir}/load_test.json", 'w') { |f| f.write(test_json_contents) }
    p test_json_contents
    p "took care of test json content"

    lb = env.load_balance_connect :dfw
    if opts[:with_repose]
      lb_ip = env.lb_service.load_balancers.find { |lb| lb.name =~ /with_repose/ }.virtual_ips.find {|ip| ip.ip_version == 'IPV4' && ip.type == 'PUBLIC' }.address
      p lb_ip
    else
      lb_ip = env.lb_service.load_balancers.find { |lb| lb.name =~ /no_repose/ }.virtual_ips.find {|ip| ip.ip_version == 'IPV4' && ip.type == 'PUBLIC' }.address
      p lb_ip
    end
    jmeter_contents = JmeterTemplate.new(start_time, end_time, 20, 60, lb_ip, File.read("#{target_dir}/test_#{opts[:app]}.jmx")).render
    p jmeter_contents 
    File.open("#{target_dir}/test_#{opts[:app]}.jmx", 'w') { |f| f.write(jmeter_contents) }
    #start tiem and stop time should both be in millis starting at 5 minutes AFTER spinup of all servers and scp'ing all files
    #modify runner file (ip, threads, start, stop, rampup) and stage 
    p "took care of jmeter json content"

    #make results directory
    Dir.mkdir("/root/repose/dist/files/apps/#{opts[:app]}/results/adhoc/current")

    #copy over configs and test setup
    Dir.mkdir("/root/repose/dist/files/apps/#{opts[:app]}/results/adhoc/current/meta")
    Dir.mkdir("/root/repose/dist/files/apps/#{opts[:app]}/results/adhoc/current/configs")
    FileUtils.cp_r("#{target_dir}/." , "/root/repose/dist/files/apps/#{opts[:app]}/results/adhoc/current/meta")
    FileUtils.cp_r("#{config_target_dir}/." , "/root/repose/dist/files/apps/#{opts[:app]}/results/adhoc/current/configs")

    #start test
    system "/root/apache-jmeter-2.9/bin/jmeter -n -t #{target_dir}/test_#{opts[:app]}.jmx -p /root/apache-jmeter-2.9/bin/load_test.properties >> /root/repose/dist/files/apps/#{opts[:app]}/results/adhoc/current/summary.log" 
  else
    p "Test is running"
  end  
end
