#!/usr/bin/env ruby

require 'fog'
require './Models/environment.rb'
require 'trollop'
require 'json'
require 'nokogiri'
require 'erb'

class SystemModelTemplate
  attr_reader :nodes, :template

  def initialize(nodes, template)
    @nodes = nodes
    @template = template
  end

  def render
    ERB.new(@template).result(binding)
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
end

Trollop::die :action, "must be specified" unless opts[:action]
Trollop::die :app, "app must be specified if action is start" unless (opts[:action] == 'start' && opts[:app]) || opts[:action] == 'stop'
p opts

if opts[:action] == 'start'
  tmp_dir = "tmp_#{DateTime.now.strftime('%Y%m%dT%H%M%S')}"

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
  p env.servers.inspect
  env.load_balance_connect :dfw
  env.tear_down
  #uncomment for the REAL THING
  env.spin_up_servers node_count
  

  #lb = env.lb_service.load_balancers.find { |lb| lb.virtual_ips.find {|ip| ip.address == '166.78.45.38'} != nil }
  lb_ip = env.lb.virtual_ips.find { |ip| ip.ip_version == 'IPV4' && ip.type == 'PUBLIC'}.address
  nodes = env.lb.nodes.map { |node| { :id => node.id, :address => node.address} }
  puts lb_ip
  puts nodes.inspect
  puts env.servers.inspect

  #modify system-model and dd xmls and stage all configs. 
  system_model_contents = SystemModelTemplate.new(nodes,File.read("#{config_target_dir}/system-model.cfg.xml")).render
  File.open("#{config_target_dir}/system-model.cfg.xml", 'w') { |f| f.write(system_model_contents) }

  #load configs
  #download repose and spin up
  #load and spin up auth and mock responders

  env.servers.select {|server| nodes.map {|node| node.address}.include? server.ipv4_address }.each do |server|
    server.scp "{onfig_target_dir}/*", "/home/repose/configs/"
    server.scp "#{target_dir}/auth_responder.js", "/home/mocks/auth_responder/server.js"
    server.scp "#{target_dir}/mock_responder.js", "/home/mocks/mock_responder/server.js"
    result = server.ssh [
     
     'nohup node \home\mocks\auth_responder\server.js &',
     'nohup node \home\mocks\mock_responder\server.js &'
    ]
  end

  #test all calls

  #spin up test servers.  save ip's.  load 1 with host image and other with slave images

  #start tiem and stop time should both be in millis starting at 5 minutes AFTER spinup of all servers and scp'ing all files
  #modify runner file (ip, threads, start, stop, rampup) and stage 

  #load runner file to host test server

end  
  
=begin
e = Environment.new
e.connect(:dfw)

e.load_balance_connect(:dfw)

#e.tear_down

#puts e.lb_service.load_balancers.first.virtual_ips.find {|ip| ip.ip_version == 'IPV4'}.address

flavor = e.service.flavors.find {
      |flavor|
      flavor.name =~ /#{Regexp.escape('4GB')}/
    }
#puts flavor.inspect
image = e.service.images.find {
      |image|
      image.name =~ /repose/
    }
#puts image.inspect


puts e.servers.inspect
puts e.lb_service.load_balancers.inspect

server = e.servers.find { |server| server.name =~ /test_repose_server_2/ }


#puts e.lb.inspect

=begin
result = server.ssh [
 'nohup node \home\mocks\auth_responder\server.js &',
 'nohup node \home\mocks\mock_responder\server.js &'
]


#steps:
#1. start auth responder
#2. cd to \home\repose
#3

#puts result.inspect

puts e.servers.inspect
puts e.custom_images.inspect
=end
