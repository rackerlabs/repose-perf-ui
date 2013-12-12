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
  name - sub application name
  description - sub application description
  configs - config location
  test - test location per type (default)
  request - request/response location (yaml file)
Usage:
       set_up_app --app <app id> --plugins <plugin list> --name <app name> --type <singular|comparison> --description <app description> --configs <config location> --test <test location> --request <request location>
where [options] are:
EOS
  opt :app, "App id", :type => :string
  opt :sub_app, "Sub app id", :type => :string
  opt :name, "Sub app name", :type => :string
  opt :description, "Sub app description", :type => :string
  opt :configs, "Config location", :type => :string
  opt :test, "Test location", :type => :string
  opt :load_test, "load test location", :type => :string
  opt :stress_test, "stress test location", :type => :string
  opt :duration_test, "duration test location", :type => :string
  opt :adhoc_test, "adhoc test location", :type => :string
  opt :request, "Request location", :type => :string
end

Trollop::die :app, "must be specified" unless opts[:app]
Trollop::die :sub_app, "must be specified" unless opts[:sub_app]
Trollop::die :name, "must be specified" unless opts[:name]
Trollop::die :test, "must be specified" unless opts[:test]
Trollop::die :request, "must be specified" unless opts[:request]
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


logger.info "append sub app to configs"
sub_app_yaml_content = {
    "id" => opts[:sub_app],
    "name" => opts[:name],
    "description" => opts[:description]
  }

logger.info "yaml content: #{sub_app_yaml_content.to_yaml}"

yaml_content = YAML.load_file(File.expand_path("config/apps/#{opts[:app]}.yaml", Dir.pwd))
yaml_content['application']['sub_apps'] = [] unless yaml_content['application']['sub_apps']
yaml_content['application']['sub_apps'] << sub_app_yaml_content 
File.open(File.expand_path("config/apps/#{opts[:app]}.yaml", Dir.pwd), 'w') {|f| f.write yaml_content.to_yaml }

yaml_content = YAML.load_file(File.expand_path("config/apps/dev_#{opts[:app]}.yaml", Dir.pwd))
yaml_content['application']['sub_apps'] = [] unless yaml_content['application']['sub_apps']
yaml_content['application']['sub_apps'] << sub_app_yaml_content 
File.open(File.expand_path("config/apps/dev_#{opts[:app]}.yaml", Dir.pwd), 'w') {|f| f.write yaml_content.to_yaml }

yaml_content = YAML.load_file(File.expand_path("config/apps/test_#{opts[:app]}.yaml", Dir.pwd))
yaml_content['application']['sub_apps'] = [] unless yaml_content['application']['sub_apps']
yaml_content['application']['sub_apps'] << sub_app_yaml_content 
File.open(File.expand_path("config/apps/test_#{opts[:app]}.yaml", Dir.pwd), 'w') {|f| f.write yaml_content.to_yaml }

logger.info "now get into redis"
redis = Redis.new({:host => config['redis']['host'], :port => config['redis']['port'], :db => config['redis']['db']})
logger.info "we're connected here: #{redis}"

Dir.glob("#{opts[:configs]}/**/*").each do |f|
  unless File.directory?(f)
    logger.info "log this config: #{f}"
    name_to_save = f.gsub(/^#{Regexp.escape(opts[:configs])}\//,"")
    directory_to_save = File.dirname(name_to_save)
    redis.rpush("#{opts[:app]}:#{opts[:sub_app]}:setup:configs", "{\"name\":\"#{name_to_save}\",\"location\":\"/#{config['storage_info']['prefix']}/#{opts[:app]}/#{opts[:sub_app]}/setup/configs/#{name_to_save}")
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
end
  
logger.info "now add the meta info"
redis.hmset("#{opts[:app]}:#{opts[:sub_app]}:setup:meta", "test_load_jmeter", "{ \"host\":"", \"startdelay\":10, \"rampup\":10, \"duration\":3600, \"rampdown\":10, \"throughput\":500}", "test_stress_jmeter", "{ \"host\":"", \"startdelay\":10, \"rampup\":5, \"duration\":300, \"rampup_threads\":5, \"maxthreads\":500}")

logger.info "now create test script for: #{opts[:test]}"
["adhoc","load","duration","stress"].each do |test_type|
  test_location = ""
  if opts["#{test_type}_test".to_sym]
    test_location = opts["#{test_type}_test".to_sym]
  else
    test_location = opts[:test]
  end
  
  redis.rpush("#{opts[:app]}:#{opts[:sub_app]}:tests:setup:script", "{\"type\":\"jmeter\", \"test\":\"#{test_type}\", \"name\":\"#{File.basename(test_location)}\",\"location\":\"/#{config['storage_info']['prefix']}/#{opts[:app]}/#{opts[:sub_app]}/setup/meta/#{test_type}/#{File.basename(test_location)}\"}")

  if config['storage_info']['destination'] == 'localhost'
    FileUtils.mkdir_p "#{config['storage_info']['path']}/#{config['storage_info']['prefix']}/#{opts[:app]}/#{opts[:sub_app]}/setup/meta/#{test_type}"
    FileUtils.cp(test_location, "#{config['storage_info']['path']}/#{config['storage_info']['prefix']}/#{opts[:app]}/#{opts[:sub_app]}/setup/meta/#{test_type}/")
  else
    Net::SSH.start(config['storage_info']['destination'], config['storage_info']['user']) do |ssh|
        ssh.exec!("mkdir -p #{config['storage_info']['path']}/#{config['storage_info']['prefix']}/#{opts[:app]}/#{opts[:sub_app]}/setup/meta/#{test_type}")
    end
    Net::SCP.upload!(
        config['storage_info']['destination'], 
        config['storage_info']['user'], 
        test_location, 
        "#{config['storage_info']['path']}/#{config['storage_info']['prefix']}/#{opts[:app]}/#{opts[:sub_app]}/setup/meta/#{test_type}/"
      )
  end
end

  
logger.info "finally log the request and response"
request_response = YAML.load_file(opts[:request])
redis.set("#{opts[:app]}:#{opts[:sub_app]}:tests:setup:request_response:request", request_response["request"].to_json)
redis.set("#{opts[:app]}:#{opts[:sub_app]}:tests:setup:request_response:response", request_response["response"].to_json)

logger.info "we are done!"
