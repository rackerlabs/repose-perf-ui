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
  configs - config location
Usage:
       config_update --app <app id> --name <app name> --type <singular|comparison> --description <app description> --configs <config location> --test <test location> --request <request location> --responders
where [options] are:
EOS
  opt :app, "App id", :type => :string
  opt :sub_app, "Sub app id", :type => :string
  opt :configs, "Config location", :type => :string
end

Trollop::die :app, "must be specified" unless opts[:app]
Trollop::die :sub_app, "must be specified" unless opts[:sub_app]
logger.debug opts

#1. in config/apps append to <app>.yaml, dev_<app>.yaml, test_<app>.yaml
=begin

application:
  sub_apps:
   -
     id: <sub_app>
     name: <name>
     description: <description>
=end

#3. create redis tags
=begin
   config_directory.files.each do |file|
     redis.rpush "<app>:<sub_app>:setup:configs" "{\"name\":\"<file>\",\"location\":\"/storage_info[prefix]/<app>/<sub_app>/setup/configs/<file>\"}"
     upload to storage_info[user]@storage_info[destination]:storage_info[path]/storage_info[prefix]/<app>/<sub_app>/setup/configs/<file>
   end

   redis.hmset "<app>:<sub_app>:tests:setup:script" type jmeter test "{\"name\":\"<file_name>\",\"location\":\"/storage_info[prefix]/<app>/<sub_app>/setup/meta/<file_name>\"}"
   upload to storage_info[user]@storage_info[destination]:storage_info[path]/storage_info[prefix]/<app>/<sub_app>/setup/meta/<file_name>

   redis.hmset "<app>:<sub_app>:setup:meta" test_load_jmeter "{ \"host\":"", \"startdelay\":10, \"rampup\":10, \"duration\":3600, \"rampdown\":10, \"throughput\":500}" test_stress_jmeter "{ \"host\":"", \"startdelay\":10, \"rampup\":5, \"duration\":300, \"rampup_threads\":5, \"maxthreads\":500}"
=end

logger.info "now get into redis"
redis = Redis.new({:host => 'localhost', :port => 6379, :db => 1})
logger.info "we're connected here: #{redis}"


Dir.glob("#{opts[:configs]}/**/*").each do |f|
  logger.info "we are here"
  unless File.directory?(f)
    logger.info "log this config: #{f}"
    name_to_save = f.gsub(/^#{Regexp.escape(opts[:configs])}\//,"")
    directory_to_save = File.dirname(name_to_save)
    redis.rpush("#{opts[:app]}:#{opts[:sub_app]}:setup:configs", "{\"name\":\"#{name_to_save}\",\"location\":\"/#{config['storage_info']['prefix']}/#{opts[:app]}/#{opts[:sub_app]}/setup/configs/#{name_to_save}\"}")
    if config['storage_info']['destination'] == 'localhost'
      FileUtils.mkdir_p "#{config['storage_info']['path']}/#{config['storage_info']['prefix']}/#{opts[:app]}/#{opts[:sub_app]}/setup/configs/#{directory_to_save}"
      FileUtils.cp(f, "#{config['storage_info']['path']}/#{config['storage_info']['prefix']}/#{opts[:app]}/#{opts[:sub_app]}/setup/configs/#{directory_to_save}/")
    else
      Net::SSH.start(config['storage_info']['destination'], config['storage_info']['user']) do |ssh|
          ssh.exec!("mkdir -p #{config['storage_info']['path']}/#{config['storage_info']['prefix']}/#{opts[:app]}/#{opts[:sub_app]}/setup/configs/#{directory_to_save}")
      end
      Net::SCP.upload!(
          config['storage_info']['destination'],
          config['storage_info']['user'],
          f,
          "#{config['storage_info']['path']}/#{config['storage_info']['prefix']}/#{opts[:app]}/#{opts[:sub_app]}/setup/configs/#{directory_to_save}"
        )
    end
  end
end if opts[:configs]

logger.info "we are done!"
