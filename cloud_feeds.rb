#!/usr/bin/env ruby

require 'trollop'
require 'json'
require 'logging'
require 'yaml'
require 'redis'
require 'net/scp'
require 'rest_client'
require 'securerandom'

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
  version "fog wrapper for cloud feeds pt 0.0.1 - 2014 Dimitry Ushakov"
  banner <<-EOS
Responsible for starting test and stopping test.  Linux only.
Attributes:
  app - this is an application name.  always atom_hopper
  sub_app - this is the sub app name. this is the configuration id (staging, etc.)
  test_type - can either be load, adhoc, duration, or stress
  action - either start or stop
  length - load test length in minutes
  description - description of the test
  name - test name
  runner - which runner to use to run the test (jmeter, gatling, etc)
  test_agent - remote test agent
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
  opt :runner, "Runner", :type => :string
  opt :test_agent, "Test agent", :type => :string
end

Trollop::die :action, "must be specified" unless opts[:action]
Trollop::die :sub_app, "must be specified" unless opts[:sub_app]
Trollop::die :test_type, "must be specified" unless opts[:test_type]
Trollop::die :name, "must be specified" unless opts[:name]
Trollop::die :test_agent, "must be specified" unless opts[:test_agent]

logger.debug opts

if opts[:action] == 'stop'
  
  logger.debug "config: #{config} and logger: #{logger}"
  RETRY_COUNT = 3

  run_succeeded = false
  retry_counter = 0
  while !run_succeeded && retry_counter < RETRY_COUNT
    begin
      Net::SSH.start(opts[:test_agent], 'root') do |ssh|
        ssh.exec!("/home/apache/apache-jmeter-2.9/bin/shutdown.sh")
      end
      run_succeeded = true
    rescue Exception => e
      logger.info e
      logger.info e.backtrace
      retry_counter = retry_counter + 1
    end
  end

  #stop
  if File.exists?(File.expand_path("atom_execution.yaml", Dir.pwd))
    test_yaml = YAML.load_file(File.expand_path("atom_execution.yaml", Dir.pwd))
    guid = test_yaml["guid"]
  end

  raise ArgumentError, "no guid" unless guid
  
  request_body = {
    "guid" =>  guid,
    "servers" => {
      "results" => {
        "server" => opts[:test_agent],
        "user" => "root",
        "path" => "/home/apache/test/summary.log"
      }
    }
  }

  request_body["plugins"] = [
    {
    "id" => "graphite_rest_plugin",
    "servers" => [
        {
          "server" => 'graphite.staging.ord1.us.ci.rackspace.net',
          "target" => [
            "atomhopper.repose.us.ord1.staging.atom-*.perftest1.*",
            "atomhopper.tomcat.us.ord1.staging.*.perftest1.*.*.*.*",
            "atomhopper.cloudfeeds.repose.us.ord1.staging.*.perftest1.*"
          ]
        }
      ] 
    },
    {
    "id" => "newrelic_rest_plugin",
    "fields" => [
        {
          "field" => 'average_response_time',
          "api-key" => 'cc8af2051d7a43682afe0ed7ca4104dcc3f877cde849f31',
          "account" => '378253',
          "agent" => '2160846',
          "metric" => [
            "Database/all",
            "Servlet/org.atomhopper.AtomHopperLogCheckServlet/service",
            "Servlet/org.apache.catalina.servlets.DefaultServlet/service",
            "Servlet/org.atomhopper.AtomHopperVersionServlet/service",
            "Database/ResultSet",
            "Servlet/org.atomhopper.AtomHopperServlet/service",
            "Java/org.atomhopper.AtomHopperServlet/init",
            "Java/ch.qos.logback.classic.selector.servlet.ContextDetachingSCL/contextInitialized",
            "Java/org.apache.jasper.servlet.JspServlet/init",
            "Java/org.atomhopper.ExternalConfigLoaderContextListener/contextInitialized",
            "Java/org.springframework.web.context.ContextLoaderListener/contextInitialized",
            "ClientApplication/VQcOWFFRGwEIUlVUBQM=/all",
            "Database/sequences/select",
            "Database/getConnection",
            "Stalls",
            "WebTransaction/Uri/atommetrics",
            "DatabaseErrors/all",
            "OtherTransaction/Initializer/ServletContextListener/org.atomhopper.ExternalConfigLoaderContextListener/contextDestroyed",
            "OtherTransaction/Initializer/ServletContextListener/org.springframework.web.context.ContextLoaderListener/contextDestroyed",
            "WebTransaction/Servlet/default",
            "ClientApplication/378253#2149571/all",
            "Database/entries/insert",
            "Database/insert",
            "Database/select",
            "Database/entries/select",
            "WebTransaction/Servlet/Atom-Hopper",
            "Database/allOther",
            "Database/allWeb",
            "RequestDispatcher",
            "WebTransaction",
            "OtherTransaction/Initializer/ServletInit",
            "HttpDispatcher",
            "OtherTransaction/all",
            "Instance/connects"
          ]
        }
      ] 
    }
  ]

  logger.info "http://localhost/#{opts[:app]}/applications/#{opts[:sub_app]}/#{opts[:test_type]}/stop"
  logger.info request_body.to_json
  begin
    response = RestClient::Request.execute(:method => :post, :url => "http://localhost/#{opts[:app]}/applications/#{opts[:sub_app]}/#{opts[:test_type]}/stop", :timeout => -1,  :payload => request_body.to_json)
  rescue Exception => e
    p e.backtrace
  end

  logger.debug response
  logger.debug response.code

  logger.info "remove the used values from yaml"
  
  File.delete(File.expand_path("atom_execution.yaml", Dir.pwd))
  
  Net::SSH.start(opts[:test_agent], 'root') do |ssh|
    ssh.exec!("rm -rf /home/apache/test/*")
  end
elsif opts[:action] == 'start'
  logger.debug "config: #{config} and logger: #{logger}"

  logger.info "get into redis"
  redis = Redis.new({:host => config['redis']['host'], :port => config['redis']['port'], :db => config['redis']['db']})
  logger.debug "redis: #{redis}"
  config_list = redis.lrange("#{opts[:app]}:#{opts[:sub_app]}:setup:configs", 0, -1)

  guid = SecureRandom.uuid
  
  logger.info "get meta information"

  Net::SSH.start(opts[:test_agent], 'root') do |ssh|
    ssh.exec!("mkdir -p /home/apache/test")
    ssh.exec!("rm -rf /home/apache/test/*")
  end
  
  logger.info "get jmeter stuff from redis"
  test_json = redis.hget("#{opts[:app]}:#{opts[:sub_app]}:setup:meta", "test_#{opts[:test_type]}_#{opts[:runner]}")
  
  raise ArgumentError, "invalid test" unless test_json
  test_data = JSON.parse(test_json)
  
  test_script_list = redis.lrange("#{opts[:app]}:#{opts[:sub_app]}:tests:setup:script", 0, -1)
  raise ArgumentError, "no tests found" unless test_script_list
  
  test_script = JSON.parse(test_script_list.find {|s| parsed_result = JSON.parse(s) ; parsed_result['type'] == opts[:runner] and parsed_result['test'] == opts[:test_type]})
  if config['storage_info']['destination'] == 'localhost'
    Net::SCP.upload!(
      opts[:test_agent], 
      'root', 
      "#{config['storage_info']['path']}/#{test_script['location']}", 
      "/home/apache/test/"
    )
  else
    tmp_dir = "/tmp/#{guid}/"
    FileUtils.mkpath tmp_dir unless File.exists?(tmp_dir)
    Net::SCP.download!(
      config['storage_info']['destination'], 
      config['storage_info']['user'], 
      test_script['location'], 
      tmp_dir
    ) 

    #second, upload to remote
    Net::SCP.upload!(
      opts[:test_agent], 
      'root', 
      "/tmp/#{guid}/#{name}", 
      "/home/apache/test/"
    )

    FileUtils.rm_rf("/tmp/#{guid}")
  end

  host = opts[:target_server]
  startdelay = test_data["startdelay"]
  rampup = test_data["rampup"]
  duration = opts[:length] ? opts[:length] : test_data["duration"]

  request_body = {"length" =>  duration, "name" => opts[:name], "runner" => opts[:runner] }
  request_body["description"] = opts[:description] if opts[:description]

  guid = nil


  logger.info "http://localhost/#{opts[:app]}/applications/#{opts[:sub_app]}/#{opts[:test_type]}/start"
  logger.info request_body.to_json
  response = RestClient.post "http://localhost/#{opts[:app]}/applications/#{opts[:sub_app]}/#{opts[:test_type]}/start", request_body.to_json
  logger.debug response
  logger.debug response.code

  raise ArgumentError unless response.code == 200

  test_yaml = {"guid" => JSON.parse(response)["guid"]}

  File.open(File.expand_path("atom_execution.yaml", Dir.pwd), 'w') {|f| f.write test_yaml.to_yaml }

  test_duration = duration * 60
  case opts[:test_type]
    when "load"
      rampdown = test_data["rampdown"] 
      throughput = test_data["throughput"]
      logger.info "ssh root@#{opts[:test_agent]} -f 'nohup /home/apache/apache-jmeter-2.9/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.9/bin/jmeter.properties -Jhost=#{host} -Jstartdelay=#{startdelay} -Jrampup=#{rampup} -Jduration=#{test_duration} -Jrampdown=#{rampdown} -Jthroughput=#{throughput} -Jport=80 >> /home/apache/test/summary.log & '"
      system "ssh root@#{opts[:test_agent]} -f 'nohup /home/apache/apache-jmeter-2.9/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.9/bin/jmeter.properties -Jhost=#{host} -Jstartdelay=#{startdelay} -Jrampup=#{rampup} -Jduration=#{test_duration} -Jrampdown=#{rampdown} -Jthroughput=#{throughput} -Jport=80 -l /home/apache/test/response.jtl >> /home/apache/test/summary.log & '"

      sleep(test_duration)
    when "duration"
      rampdown = test_data["rampdown"] 
      throughput = test_data["throughput"]
      logger.info "ssh root@#{opts[:test_agent]} -f 'nohup /home/apache/apache-jmeter-2.9/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.9/bin/jmeter.properties -Jhost=#{host} -Jstartdelay=#{startdelay} -Jrampup=#{rampup} -Jduration=#{test_duration} -Jrampdown=#{rampdown} -Jthroughput=#{throughput} -Jport=80 >> /home/apache/test/summary.log & '"
      system "ssh root@#{opts[:test_agent]} -f 'nohup /home/apache/apache-jmeter-2.9/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.9/bin/jmeter.properties -Jhost=#{host} -Jstartdelay=#{startdelay} -Jrampup=#{rampup} -Jduration=#{test_duration} -Jrampdown=#{rampdown} -Jthroughput=#{throughput} -Jport=80 -l /home/apache/test/response.jtl >> /home/apache/test/summary.log & '"

      sleep(60)
      logger.info Net::SSH.start(opts[:test_agent],'root') {|ssh| ssh.exec!("lsof -i :4445")}
      total_running_time = 0
      while Net::SSH.start(opts[:test_agent],'root') {|ssh| ssh.exec!("lsof -i :4445")} and total_running_time < 3600
        sleep(60)
        total_running_time = total_running_time + 60
        logger.info Net::SSH.start(opts[:test_agent],'root') {|ssh| ssh.exec!("lsof -i :4445")}
        logger.info total_running_time
      end
    when "stress"  
      rampup_threads = test_data["rampup_threads"]  
      maxthreads = test_data["maxthreads"]
      logger.info "ssh root@#{opts[:test_agent]} -f 'nohup /home/apache/apache-jmeter-2.9/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.9/bin/jmeter.properties -Gstartdelay=#{startdelay} -Grampup=#{rampup} -Gduration=#{test_duration} -Grampup_threads=#{rampup_threads} -Gthreads=#{maxthreads} -Gmaxthreads=#{maxthreads} -Gport=80 -l /home/apache/test/response.jtl -R 10.23.246.100,10.23.244.38 >> /home/apache/test/summary.log & '"
      system "ssh root@#{opts[:test_agent]} -f 'nohup /home/apache/apache-jmeter-2.9/bin/jmeter -n -t /home/apache/test/#{test_script['name']} -p /home/apache/apache-jmeter-2.9/bin/jmeter.properties -Gstartdelay=#{startdelay} -Grampup=#{rampup} -Gduration=#{test_duration} -Grampup_threads=#{rampup_threads} -Gthreads=#{maxthreads} -Gmaxthreads=#{maxthreads}  -l /home/apache/test/response.jtl -R 10.23.246.100,10.23.244.38 >> /home/apache/test/summary.log & '"

      sleep(60)
      logger.info Net::SSH.start(opts[:test_agent],'root') {|ssh| ssh.exec!("lsof -i :4445")}
      total_running_time = 0
      while Net::SSH.start(opts[:test_agent],'root') {|ssh| ssh.exec!("lsof -i :4445")} and total_running_time < 3600
        sleep(60)
        total_running_time = total_running_time + 60
        logger.info Net::SSH.start(opts[:test_agent],'root') {|ssh| ssh.exec!("lsof -i :4445")}
        logger.info total_running_time
      end
    else
      raise ArgumentError, "invalid test type"
    end
end
