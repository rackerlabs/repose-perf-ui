#!/usr/bin/env ruby

require 'trollop'
require 'json'
require 'logging'
require 'redis'
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

config = YAML.load_file(File.expand_path("config/config.yaml", Dir.pwd))
logger.debug "configuration file: #{config}"

opts = Trollop::options do
  version "quick script to set up application for hermes viewer 0.0.1 - 2013 Dimitry Ushakov"
  banner <<-EOS
Required parameters:
  app - application id
  plugins - plugin list (comma delimited)
  name - application name
  description - application description
  type - singular or comparison application
  test - test location
Usage:
       set_up_app --app <app id> --plugins <plugin list> --name <app name> --type <singular|comparison> --description <app description>
where [options] are:
EOS
  opt :app, "App id", :type => :string
  opt :plugins, "Plugin list", :type => :string
  opt :name, "App name", :type => :string
  opt :type, "App type", :type => :string
  opt :description, "App description", :type => :string
end

Trollop::die :app, "must be specified" unless opts[:app]
Trollop::die :name, "must be specified" unless opts[:name]
Trollop::die :type, "must be specified" unless opts[:type]
logger.debug opts

#1. in config/apps create <app>.yaml, dev_<app>.yaml, test_<app>.yaml
=begin 
  
application:
  name: <name>
  description: <description>
  location: apps/<app>/bootstrap.rb
  type: <type>
  plugins:
  plugins.each do |plugin_id|
   - location: plugins/<plugin_id>/plugin.rb
  end
  sub_apps: 
=end

#2. create apps/<app>/bootstrap.rb
=begin
  require 'fileutils'
  require 'yaml'
  require 'logging'
  require 'redis'
  require 'open-uri'
  require File.expand_path("apps/bootstrap.rb", Dir.pwd)
  
  module Apps
    class <app in camel case>Bootstrap < Bootstrap
   
  
      def initialize(environment = :production, redis_info = nil, logger = nil)
        if environment == :production
          @config = YAML.load_file(File.expand_path("config/apps/<app>.yaml", Dir.pwd))
        elsif environment == :test
          @config = YAML.load_file(File.expand_path("config/apps/test_<app>.yaml", Dir.pwd))
        elsif environment == :development
          @config = YAML.load_file(File.expand_path("config/apps/dev_<app>.yaml", Dir.pwd))
        end
  
        super(redis_info, logger)      
      end
    end
  end
=end

#3. create redis tags
=begin

   redis.hmset "<app>:<sub_app>:tests:setup:script" type jmeter test "{\"name\":\"<file_name>\",\"location\":\"/storage_info[prefix]/<app>/<sub_app>/setup/meta/<file_name>\"}"
   upload to storage_info[user]@storage_info[destination]:storage_info[path]/storage_info[prefix]/<app>/<sub_app>/setup/meta/<file_name>
   
   redis.hmset "<app>:<sub_app>:setup:meta" test_load_jmeter "{ \"host\":"", \"startdelay\":10, \"rampup\":10, \"duration\":3600, \"rampdown\":10, \"throughput\":500}" test_stress_jmeter "{ \"host\":"", \"startdelay\":10, \"rampup\":5, \"duration\":300, \"rampup_threads\":5, \"maxthreads\":500}" 
=end

logger.info "create config files in config/apps"
yaml_content = {
  "application" => {
    "name" => opts[:name],
    "description" => opts[:description],
    "location" => "apps/#{opts[:app]}/bootstrap.rb",
    "type" => opts[:type]
  }
}

plugins = []
opts[:plugins].split(',').each do |plugin|
  plugins << {"location" => "plugins/#{plugin}/plugin.rb"}
end if opts[:plugins]
yaml_content["application"]["plugins"] = plugins

logger.info "yaml content: #{yaml_content.to_yaml}"

FileUtils.mkpath File.expand_path("config/apps", Dir.pwd) unless File.exists?(File.expand_path("config/apps", Dir.pwd))
File.open(File.expand_path("config/apps/#{opts[:app]}.yaml", Dir.pwd), 'w') {|f| f.write yaml_content.to_yaml }
File.open(File.expand_path("config/apps/test_#{opts[:app]}.yaml", Dir.pwd), 'w') {|f| f.write yaml_content.to_yaml }
File.open(File.expand_path("config/apps/dev_#{opts[:app]}.yaml", Dir.pwd), 'w') {|f| f.write yaml_content.to_yaml }

bootstrap = "  require 'fileutils'
  require 'yaml'
  require 'logging'
  require 'redis'
  require 'open-uri'
  require File.expand_path(\"apps/bootstrap.rb\", Dir.pwd)
  
  module Apps
    class #{opts[:app].capitalize.gsub(/_./) {|l| l[1].capitalize}}Bootstrap < Bootstrap
   
  
      def initialize(environment = :production, redis_info = nil, logger = nil)
        if environment == :production
          @config = YAML.load_file(File.expand_path(\"config/apps/#{opts[:app]}.yaml\", Dir.pwd))
        elsif environment == :test
          @config = YAML.load_file(File.expand_path(\"config/apps/test_#{opts[:app]}.yaml\", Dir.pwd))
        elsif environment == :development
          @config = YAML.load_file(File.expand_path(\"config/apps/dev_#{opts[:app]}.yaml\", Dir.pwd))
        end
  
        super(redis_info, logger)      
      end
    end
  end"

FileUtils.mkpath File.expand_path("apps/#{opts[:app]}", Dir.pwd) unless File.exists?(File.expand_path("apps/#{opts[:app]}", Dir.pwd))
File.open(File.expand_path("apps/#{opts[:app]}/bootstrap.rb", Dir.pwd), 'w') {|f| f.write bootstrap }

