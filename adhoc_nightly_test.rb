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
require_relative './repose_helper.rb'
require_relative './repose_config_helper.rb'
require_relative './repose_plugin_helper.rb'
require_relative './repose_responder_helper.rb'
require_relative './repose_test_helper.rb'

RETRY_COUNT = 3

environment_hash = {
 :atom_hopper => :dfw,
 :translation => :dfw,
 :identity => :dfw,
 :dbaas => :dfw,
 :auto_scale => :dfw,
 :psl => :dfw,
 :cloud_queues => :dfw,
 :connection_pool => :dfw
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
  branch - specifies branch.  Defaults to master
  flavor_type - can either be original or performance
  runner - which runner to use to run the test (jmeter, gatling, etc)
  test_id - specifies test id
  with_repose - whether repose or origin target server
Usage:
       nightly_test --app repose --sub-app <sub app name> --test-type <load|duration|benchmark> --action <start|stop> --length 60 --description <some desc> --release master --branch master --flavor-type performance --runner jmeter --test-id 0 --with-repose true
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
  opt :branch, "Specify Branch", :type => :string
  opt :flavor_type, "Flavor type", :type => :string
  opt :runner, "Runner", :type => :string
  opt :test_id, "Test id", :type => :int
  opt :with_repose, "Boolean repose", :type => :boolean
  opt :extra_ear, "Extra ears containing filters not in Repose", :type => :string
end

Trollop::die :action, "must be specified" unless opts[:action]
Trollop::die :sub_app, "must be specified" unless opts[:sub_app]
Trollop::die :test_type, "must be specified" unless opts[:test_type]
Trollop::die :name, "must be specified" unless opts[:name]

logger.debug opts

if opts[:action] == 'stop'
  
  logger.debug "config: #{config} and logger: #{logger}"
  env = SnapshotComparer::Models::Environment.new(config, logger)
  env.connect(environment_hash[opts[:sub_app].to_sym])
  env.load_balance_connect(environment_hash[opts[:sub_app].to_sym])

  test_agent = SnapshotComparer::Models::Servers.new.get_test_ip(logger, env, opts[:test_id])

  shutdown_jmeter(RETRY_COUNT,logger, test_agent)
  server_ip_info = get_ips(env,opts[:flavor_type], opts[:with_repose], opts[:test_id], logger)

  begin
    #stop
    if File.exists?(File.expand_path("test_execution.yaml", Dir.pwd))
      test_yaml = YAML.load_file(File.expand_path("test_execution.yaml", Dir.pwd))
      if test_yaml and test_yaml.find { |t| t.has_key?("name") and t["name"] == opts[:app]}
        app_name = test_yaml.find { |t| t.has_key?("name") and t["name"] == opts[:app]}
        if app_name and app_name["sub_app"].find {|t|  t.has_key?("name") and t["name"] == opts[:sub_app]}
          sub_app_name = app_name["sub_app"].find {|t|  t.has_key?("name") and t["name"] == opts[:sub_app]}
          if sub_app_name and sub_app_name["test_type"].find {|t| t.has_key?("name") and t["name"] == opts[:test_type]}
            test_type = sub_app_name["test_type"].find {|t| t.has_key?("name") and t["name"] == opts[:test_type]}
            if opts[:with_repose]
              guid = test_type["repose_guid"]
            else
              guid = test_type["origin_guid"]
            end
          end
        end
      end
    end

    raise ArgumentError, "no guid" unless guid
  
    request_body = set_up_stop_test_request_body(guid, test_agent, opts[:with_repose], server_ip_info)

    logger.info "http://localhost/#{opts[:app]}/applications/#{opts[:sub_app]}/#{opts[:test_type]}/stop"
    logger.info request_body.to_json
    response = RestClient::Request.execute(:method => :post, :url => "http://localhost/#{opts[:app]}/applications/#{opts[:sub_app]}/#{opts[:test_type]}/stop", :timeout => -1,  :payload => request_body.to_json)
  rescue Exception => e
    logger.error e.backtrace
  ensure
    clean_up_nodes(opts[:with_repose], server_ip_info, "root", logger)

    logger.info "remove the used values from yaml"
    if File.exists?(File.expand_path("test_execution.yaml", Dir.pwd))
      test_yaml = YAML.load_file(File.expand_path("test_execution.yaml", Dir.pwd))
      if test_yaml and test_yaml.find { |t| t.has_key?("name") and t["name"] == opts[:app]}
        app_name = test_yaml.find { |t| t.has_key?("name") and t["name"] == opts[:app]}
        if app_name and app_name["sub_app"].find {|t|  t.has_key?("name") and t["name"] == opts[:sub_app]}
          sub_app_name = app_name["sub_app"].find {|t|  t.has_key?("name") and t["name"] == opts[:sub_app]}
          if sub_app_name and sub_app_name["test_type"].find {|t| t.has_key?("name") and t["name"] == opts[:test_type]}
            test_type = sub_app_name["test_type"].find {|t| t.has_key?("name") and t["name"] == opts[:test_type]}
            sub_app_name["test_type"].delete(test_type) unless opts[:with_repose]
          end
        end
      end
    end
  
    logger.info "yaml content: #{test_yaml.to_yaml}"

    File.open(File.expand_path("test_execution.yaml", Dir.pwd), 'w') {|f| f.write test_yaml.to_yaml }

    Net::SSH.start(test_agent, 'root') do |ssh|
      ssh.exec!("rm -rf /home/apache/test/*")
    end
  end

  logger.debug response
  logger.debug response.code

elsif opts[:action] == 'start'
  logger.debug "config: #{config} and logger: #{logger}"
  logger.info "spin up necessary servers (2 for target and 1 for test) from specific environment"
  env = SnapshotComparer::Models::Environment.new(config, logger)
  env.connect(environment_hash[opts[:sub_app].to_sym])
  env.load_balance_connect(environment_hash[opts[:sub_app].to_sym])
  
  logger.info "get into redis"
  redis = Redis.new({:host => config['redis']['host'], :port => config['redis']['port'], :db => config['redis']['db']})
  logger.debug "redis: #{redis}"
  redis.set("#{opts[:app]}:test:#{opts[:sub_app]}:#{opts[:test_type]}:temp_start", "BUILDING")

  server_ip_info = get_ips(env, opts[:flavor_type], opts[:with_repose], opts[:test_id], logger)

  redis.set("#{opts[:app]}:test:#{opts[:sub_app]}:#{opts[:test_type]}:temp_start", "BUILDING - retrieved cloud servers")
  slave_test_agent_list = SnapshotComparer::Models::Servers.new.get_slave_test_ip(logger,env,opts[:test_id])
  logger.info "slaves: #{slave_test_agent_list.inspect}"

  redis.set("#{opts[:app]}:test:#{opts[:sub_app]}:#{opts[:test_type]}:temp_start", "BUILDING - retrieved test agents")

  guid = SecureRandom.uuid
  
  logger.info "get meta information"

  meta_information = redis.hgetall("#{opts[:app]}:#{opts[:sub_app]}:setup:meta")
  main_responders = meta_information.select {|m,_| m =~ /responder\|main\|/}
  secondary_responders = meta_information.select {|m,_| m =~ /responder\|secondary\|/}
  logger.info "main responders: #{main_responders}"
  logger.info "secondary responders: #{secondary_responders}"


  if opts[:with_repose] and opts[:release] and opts[:release] == 'master'
    redis.set("#{opts[:app]}:test:#{opts[:sub_app]}:#{opts[:test_type]}:temp_start", "BUILDING - git clone rackerlabs/repose")
    branch = opts[:branch] ? opts[:branch] : 'master'
    system "rm -rf ~/repose_repo/repose ; mkdir ~/repose_repo/repose ; cd ~/repose_repo/repose ; git init ; git pull https://github.com/rackerlabs/repose #{branch} ; mvn clean install -U -DskipTests; "
    redis.set("#{opts[:app]}:test:#{opts[:sub_app]}:#{opts[:test_type]}:temp_start", "BUILDING - repo cloned")
  end

  is_started_successfully = false

  server_ip_info[:nodes].each do |server|
    upload_responders(logger, opts[:with_repose], main_responders, secondary_responders, config, guid, server) 
    redis.set("#{opts[:app]}:test:#{opts[:sub_app]}:#{opts[:test_type]}:temp_start", "BUILDING - uploaded responders to #{server}")

    if opts[:with_repose]
      redis.set("#{opts[:app]}:test:#{opts[:sub_app]}:#{opts[:test_type]}:temp_start", "BUILDING - uploading configs to #{server}")
      upload_config_list(redis, opts[:app], opts[:sub_app], server_ip_info, config, guid, server, logger)
      redis.set("#{opts[:app]}:test:#{opts[:sub_app]}:#{opts[:test_type]}:temp_start", "BUILDING - uploading plugins to #{server}")
      upload_plugins(redis, opts[:app], opts[:sub_app], config, server, logger)
      redis.set("#{opts[:app]}:test:#{opts[:sub_app]}:#{opts[:test_type]}:temp_start", "BUILDING - uploading artifacts to #{server}")
      upload_artifacts(opts[:release], opts[:extra_ear], server, logger) 
      redis.set("#{opts[:app]}:test:#{opts[:sub_app]}:#{opts[:test_type]}:temp_start", "BUILDING - starting repose on #{server}")
      if opts[:release] != "master" && opts[:release][0].to_i < 6 
        start_repose(server, logger, true)
      else
        start_repose(server, logger, false)
      end
    end

    logger.info "start logging sysstats"
    system "ssh root@#{server} -f 'sar -o /home/repose/logs/sysstats.log 30 >/dev/null 2>&1 & '"
  end

  redis.set("#{opts[:app]}:test:#{opts[:sub_app]}:#{opts[:test_type]}:temp_start", "BUILDING - setting up test agent")
  test_agent, test_data, test_script = set_up_test_agent(logger, opts[:test_id], redis, opts[:app], opts[:sub_app], opts[:test_type], opts[:runner], config, guid, env)

  host = server_ip_info[:lb]
  startdelay = test_data["startdelay"]
  rampup = test_data["rampup"]
  duration = opts[:length] ? opts[:length] : test_data["duration"]

  request_body = {"length" =>  duration, "name" => opts[:name], "runner" => opts[:runner] }
  request_body["description"] = opts[:description] if opts[:description]
  request_body["flavor_type"] = opts[:flavor_type] if opts[:flavor_type]
  request_body["release"] = opts[:release] if opts[:release]

  guid = nil
  if File.exists?(File.expand_path("test_execution.yaml", Dir.pwd)) && !opts[:with_repose]
    test_yaml = YAML.load_file(File.expand_path("test_execution.yaml", Dir.pwd))
    if test_yaml and test_yaml.find { |t| t.has_key?("name") and t["name"] == opts[:app]}
      app_name = test_yaml.find { |t| t.has_key?("name") and t["name"] == opts[:app]}
      if app_name and app_name["sub_app"].find {|t|  t.has_key?("name") and t["name"] == opts[:sub_app]}
        sub_app_name = app_name["sub_app"].find {|t|  t.has_key?("name") and t["name"] == opts[:sub_app]}
        if sub_app_name and sub_app_name["test_type"].find {|t| t.has_key?("name") and t["name"] == opts[:test_type]}
          test_type = sub_app_name["test_type"].find {|t| t.has_key?("name") and t["name"] == opts[:test_type]}
          guid = test_type["repose_guid"]
        end
      end
    end
  end
  
  request_body["comparison_guid"] = guid unless opts[:with_repose]


  redis.set("#{opts[:app]}:test:#{opts[:sub_app]}:#{opts[:test_type]}:temp_start", "BUILDING - starting the test")
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
          test_type = sub_app_name["test_type"].find {|t| t.has_key?("name") and t["name"] == opts[:test_type]}
          if opts[:with_repose] and test_type.has_key?("repose_guid")
            raise ArgumentError, "already exists!"
          elsif !opts[:with_repose] && test_type.has_key?("origin_guid")
            raise ArgumentError, "already exists!"
          elsif opts[:with_repose]
            test_type["repose_guid"] = JSON.parse(response)["guid"]
          else
            test_type["origin_guid"] = JSON.parse(response)["guid"]
          end
        else
          if opts[:with_repose]
            sub_app_name["test_type"] << {
              "name" => opts[:test_type],
              "repose_guid" => JSON.parse(response)["guid"]
            }
          else
            raise ArgumentError, "no guid for repose!"
          end
        end
      else
        if opts[:with_repose]
          app_name["sub_app"] << {
            "name" => opts[:sub_app],
            "test_type" => [{
              "name" => opts[:test_type],
              "repose_guid" => JSON.parse(response)["guid"]
            }]
          }
        else
          raise ArgumentError, "no guid for repose!"
        end
      end
    else
      if opts[:with_repose]
        test_yaml << {
          "name" => opts[:app],
          "sub_app" => [{
            "name" => opts[:sub_app],
            "test_type" => [{
              "name" => opts[:test_type],
              "repose_guid" => JSON.parse(response)["guid"]
            }]
          }]
        }
      else
        raise ArgumentError, "no guid for repose!"
      end
    end
  else
    if opts[:with_repose]
      test_yaml = [{
        "name" => opts[:app],
        "sub_app" => [{
          "name" => opts[:sub_app],
          "test_type" => [{
            "name" => opts[:test_type],
            "repose_guid" => JSON.parse(response)["guid"]
          }]
        }]
      }]
    else
      raise ArgumentError, "no guid for repose!"
    end
  end

  logger.info "yaml content: #{test_yaml.to_yaml}"

  File.open(File.expand_path("test_execution.yaml", Dir.pwd), 'w') {|f| f.write test_yaml.to_yaml }

  test_duration = duration * 60
  redis.del("#{opts[:app]}:test:#{opts[:sub_app]}:#{opts[:test_type]}:temp_start")
  case opts[:test_type]
    when "load"
      rampdown = test_data["rampdown"] 
      throughput = test_data["throughput"]
      slave_test_agent_list << test_agent
      logger.info "ssh root@#{test_agent} -f 'nohup /home/apache/apache-jmeter-2.10/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.10/bin/jmeter.properties -Ghost=#{host} -Gstartdelay=#{startdelay} -Grampup=#{rampup} -Gduration=#{test_duration} -Grampdown=#{rampdown} -Gthroughput=#{throughput} -Gport=80 -R #{slave_test_agent_list.join(',')} >> /home/apache/test/summary.log & '"
      system "ssh root@#{test_agent} -f 'nohup /home/apache/apache-jmeter-2.10/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.10/bin/jmeter.properties -Ghost=#{host} -Gstartdelay=#{startdelay} -Grampup=#{rampup} -Gduration=#{test_duration} -Grampdown=#{rampdown} -Gthroughput=#{throughput} -Gport=80 -l /home/apache/test/response.jtl -R #{slave_test_agent_list.join(',')} >> /home/apache/test/summary.log & '"
      redis.del("#{opts[:app]}:test:#{opts[:sub_app]}:#{opts[:test_type]}:temp_start")

      sleep(60)
      logger.info Net::SSH.start(test_agent,'root') {|ssh| ssh.exec!("lsof -i :4445")}
      total_running_time = 0
      while Net::SSH.start(test_agent,'root') {|ssh| ssh.exec!("lsof -i :4445")} and total_running_time < test_duration
        sleep(60)
        total_running_time = total_running_time + 60
        logger.info Net::SSH.start(test_agent,'root') {|ssh| ssh.exec!("lsof -i :4445")}
        logger.info total_running_time
      end
    when "adhoc"
      rampdown = test_data["rampdown"] 
      throughput = test_data["throughput"]
      slave_test_agent_list << test_agent
      logger.info "ssh root@#{test_agent} -f 'nohup /home/apache/apache-jmeter-2.10/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.10/bin/jmeter.properties -Ghost=#{host} -Gstartdelay=#{startdelay} -Grampup=#{rampup} -Gduration=#{test_duration} -Grampdown=#{rampdown} -Gthroughput=#{throughput} -Gport=80 -R #{slave_test_agent_list.join(',')} >> /home/apache/test/summary.log & '"
      system "ssh root@#{test_agent} -f 'nohup /home/apache/apache-jmeter-2.10/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.10/bin/jmeter.properties -Ghost=#{host} -Gstartdelay=#{startdelay} -Grampup=#{rampup} -Gduration=#{test_duration} -Grampdown=#{rampdown} -Gthroughput=#{throughput} -Gport=80 -l /home/apache/test/response.jtl -R #{slave_test_agent_list.join(',')} >> /home/apache/test/summary.log & '"
      redis.del("#{opts[:app]}:test:#{opts[:sub_app]}:#{opts[:test_type]}:temp_start")

      sleep(60)
      logger.info Net::SSH.start(test_agent,'root') {|ssh| ssh.exec!("lsof -i :4445")}
      logger.info Net::SSH.start(test_agent,'root') {|ssh| ssh.exec!("lsof -i ")}
      total_running_time = 0
      logger.info "test duration: #{test_duration}"
      while Net::SSH.start(test_agent,'root') {|ssh| ssh.exec!("lsof -i :4445")} and total_running_time < test_duration
        sleep(60)
        total_running_time = total_running_time + 60
        logger.info Net::SSH.start(test_agent,'root') {|ssh| ssh.exec!("lsof -i :4445")}
        logger.info total_running_time
      end
      logger.info "ended adhoc test"
    when "stress"  
      rampup_threads = test_data["rampup_threads"]  
      maxthreads = test_data["maxthreads"]
      logger.info "ssh root@#{test_agent} -f 'nohup /home/apache/apache-jmeter-2.10/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.10/bin/jmeter.properties -Ghost=#{host} -Gstartdelay=#{startdelay} -Grampup=#{rampup} -Gduration=#{test_duration} -Grampup_threads=#{rampup_threads} -Gmaxthreads=#{maxthreads} -Gport=80 -l /home/apache/test/response.jtl -R #{slave_test_agent_list.join(',')} >> /home/apache/test/summary.log & '"
      system "ssh root@#{test_agent} -f 'nohup /home/apache/apache-jmeter-2.10/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.10/bin/jmeter.properties -Ghost=#{host} -Gstartdelay=#{startdelay} -Grampup=#{rampup} -Gduration=#{test_duration} -Grampup_threads=#{rampup_threads} -Gmaxthreads=#{maxthreads} -Gport=80 -l /home/apache/test/response.jtl -R #{slave_test_agent_list.join(',')} >> /home/apache/test/summary.log & '"
      redis.del("#{opts[:app]}:test:#{opts[:sub_app]}:#{opts[:test_type]}:temp_start")

      sleep(60)
      logger.info Net::SSH.start(test_agent,'root') {|ssh| ssh.exec!("lsof -i :4445")}
      total_running_time = 0
      while Net::SSH.start(test_agent,'root') {|ssh| ssh.exec!("lsof -i :4445")} and total_running_time < test_duration
        sleep(60)
        total_running_time = total_running_time + 60
        logger.info Net::SSH.start(test_agent,'root') {|ssh| ssh.exec!("lsof -i :4445")}
        logger.info total_running_time
      end
    else
      raise ArgumentError, "invalid test type"
    end

end

