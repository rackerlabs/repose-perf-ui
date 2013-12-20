#!/usr/bin/env ruby

require 'trollop'
require 'json'
require 'logging'
require 'redis'
require 'yaml'
require 'net/scp'

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
  version "quick script to set up sub application for hermes viewer 0.0.1 - 2013 Dimitry Ushakov"
  banner <<-EOS
Required parameters:
  app - application id
  sub_app - sub application id
  plugin_id - plugin id
  location - file location
Usage:
       add_plugin_app --app <app id> --sub-app <sub app id> --plugin-id <plugin id> --location <file location>
where [options] are:
EOS
  opt :app, "App id", :type => :string
  opt :sub_app, "Sub app id", :type => :string
  opt :plugin_id, "Plugin id", :type => :string
  opt :location, "Plugin location", :type => :string
end

Trollop::die :app, "must be specified" unless opts[:app]
Trollop::die :sub_app, "must be specified" unless opts[:sub_app]
Trollop::die :plugin_id, "must be specified" unless opts[:plugin_id]
Trollop::die :location, "must be specified" unless opts[:location]
logger.debug opts

logger.info "now get into redis"
redis = Redis.new({:host => config['redis']['host'], :port => config['redis']['port'], :db => config['redis']['db']})
logger.info "we're connected here: #{redis}"

logger.info "now get the plugin meta info"
plugin_list = redis.hget("#{opts[:app]}:#{opts[:sub_app]}:setup:meta:plugins", opts[:plugin_id])
specific_plugin_list = []
specific_plugin_list = JSON.parse(plugin_list) if plugin_list
specific_plugin_list << {"name" => File.basename(opts[:location]), "location" => "/#{config['storage_info']['prefix']}/#{opts[:app]}/#{opts[:sub_app]}/setup/meta/plugins/#{opts[:plugin_id]}/#{File.basename(opts[:location])}"}

redis.hset("#{opts[:app]}:#{opts[:sub_app]}:setup:meta:plugins", opts[:plugin_id], specific_plugin_list.to_json)

if config['storage_info']['destination'] == 'localhost'
  FileUtils.mkdir_p "#{config['storage_info']['path']}/#{config['storage_info']['prefix']}/#{opts[:app]}/#{opts[:sub_app]}/setup/meta/plugins/#{opts[:plugin_id]}"
  FileUtils.cp(opts[:location], "#{config['storage_info']['path']}/#{config['storage_info']['prefix']}/#{opts[:app]}/#{opts[:sub_app]}/setup/meta/plugins/#{opts[:plugin_id]}/")
else
  Net::SSH.start(config['storage_info']['destination'], config['storage_info']['user']) do |ssh|
      ssh.exec!("mkdir -p #{config['storage_info']['path']}/#{config['storage_info']['prefix']}/#{opts[:app]}/#{opts[:sub_app]}/setup/meta/plugins/#{opts[:plugin_id]}")
  end
  Net::SCP.upload!(
      config['storage_info']['destination'], 
      config['storage_info']['user'], 
      opts[:location], 
      "#{config['storage_info']['path']}/#{config['storage_info']['prefix']}/#{opts[:app]}/#{opts[:sub_app]}/setup/meta/plugins/#{opts[:plugin_id]}/"
  )
end
logger.info "we are done!"
