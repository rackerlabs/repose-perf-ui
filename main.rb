require 'sinatra'
require 'json'
require 'logging'
require_relative './Models/models.rb'
require_relative  './Models/application.rb'
require_relative  './Models/test.rb'
require_relative  './Models/request.rb'
require_relative  './Models/response.rb'
require_relative  './Models/perftest.rb'
require_relative  './Models/result.rb'
require_relative  './Models/results.rb'
require_relative  './Models/configuration.rb'
require_relative  './Models/testlocation.rb'
require_relative  './Models/database.rb'
require_relative './Models/cpuresultstrategy.rb'
require_relative './Models/kernelresultstrategy.rb'
require_relative './Models/memoryswapresultstrategy.rb'
require_relative './Models/memorypageresultstrategy.rb'
require_relative './Models/memoryutilsresultstrategy.rb'
require_relative './Models/tcpfailurenetworkresultstrategy.rb'
require_relative './Models/tcpnetworkresultstrategy.rb'
require_relative './Models/ipfailurenetworkresultstrategy.rb'
require_relative './Models/ipnetworkresultstrategy.rb'
require_relative './Models/socketnetworkresultstrategy.rb'
require_relative './Models/devicefailurenetworkresultstrategy.rb'
require_relative './Models/devicenetworkresultstrategy.rb'
require_relative './Models/devicediskresultstrategy.rb'
require_relative './Models/pagingresultsstrategy.rb'

#class PerfApp < Sinatra::Base

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


  db = Models::Database.new
  db.upgrade 1
  db.load_apps (
    {
      :dbaas => Models::Application.new(0,"Cloud Databases", "cloud databases"),
      :ah => Models::Application.new(0,"Atom Hopper", "description"),
      :csl => Models::Application.new(0,"Customer Service Layer", "internal application"),
      :passthrough => Models::Application.new(0,"Passthrough (no filters)", "internal application"),
      :ddrl => Models::Application.new(0,"Dist Datastore + Rate Limiting", "internal application"),
      :metrics_on_off => Models::Application.new(0,"Metrics off setup", "internal application"),
      :custom => Models::Application.new(0,"Custom", "anything goes in here")
    } 
  )  

  app_list = db.retrieve_apps
   
  load_test_list = {
    :load_test => Models::PerfTest.new(1, 'Load Test', 'Test description'),
    :duration_test => Models::PerfTest.new(2, 'Duration Test','Test description'),
    :benchmark_test => Models::PerfTest.new(3, 'Benchmark Test','Test description'),
    :adhoc_test => Models::PerfTest.new(4, 'Adhoc Test','Test description')
  }

  results = nil

  # In your main application file
  configure do
    set :views, "#{File.dirname(__FILE__)}/views"
    set :public_dir, "#{File.dirname(__FILE__)}/public"
  end

  get '/' do
    erb :index
  end

  get '/applications' do
    erb :applications, :locals => {:application_list => app_list}
  end

  get '/applications/:name' do |name|
    app = app_list[name.to_sym]
    if app 
      app.app_id = name.to_sym
      app.request_response_list = Models::Test.new.get_setup_requests_by_name(name)
      app.config_list = Models::Configuration.new.get_by_name(name)
      app.test_location = Models::TestLocationFactory.get_by_name(name)
      erb :app_detail, :locals => {:app_detail => app}
    else
      status 404
      body "Not found"
    end
  end

  get '/applications/:name/test_download/:file_name' do |name, file_name|
    begin
      downloaded_file = Models::TestLocationFactory.get_by_name(name).download
      send_file downloaded_file, :filename => file_name, :type => 'Application/octet-stream'
    rescue ArgumentError => e
      status 404
      body e.message
    end
  end

  get '/tests' do
    erb :tests, :locals => {:application_list => app_list}
  end

  get '/tests/:name' do |name|
    app = app_list[name.to_sym]
    if app
      app.load_test_list = load_test_list
      app.app_id = name.to_sym
      erb :tests_app_detail, :locals => {:app_detail => app}
    else
      status 404
      body "Not found"
    end
  end

  get '/tests/:name/:test' do |name, test|
    app = app_list[name.to_sym]
    if app and load_test_list.keys.include?(test.to_sym)
      app.results = Results::LiveSummaryResults.start_running_results(name, test.chomp('_test'))
      app.result_set_list = app.results.summary_results 
      app.test_type = test
      erb :tests_app_test_detail, :locals => {:app_detail => app }
    else
      status 404
      body "Not found"
    end
  end

  get '/tests/:name/:test/metric/:metric' do |name, test, metric|
    #parse from summary file and jmx filei
    app = app_list[name.to_sym]
    if app and load_test_list.keys.include?(test.to_sym)
      temp_results = []
      live_results = Results::LiveSummaryResults.running_tests[name][test.chomp('_test')]
      if live_results && live_results.summary_results[0].respond_to?(metric.to_sym)
        live_results.summary_results.each { |result| temp_results << [result.date, result.send(metric.to_sym).to_f] }
      end
      content_type :json
      response = { :results => temp_results, :ended => live_results.test_ended}
    else
      status 404
      response = { :results => [], :ended => true}
    end
    body response.to_json
  end

  get '/tests/:name/:test/metric/:metric/live' do |name, test, metric|
    #get last values from summary file and jmx file
    app = app_list[name.to_sym]
    if app and load_test_list.keys.include?(test.to_sym) and !app.results.test_ended
      temp_results = []
      if app.results && app.results.summary_results[0].respond_to?(metric.to_sym)
        app.results.new_summary_values.each { |result| temp_results << [result.date, result.send(metric.to_sym).to_f] }
      end
      content_type :json
      response = { :results => temp_results, :ended => app.results.test_ended}
    else
      status 404
      response = { :results => [], :ended => true}
    end
    body response.to_json
  end

  get '/results' do
    erb :results, :locals => {:application_list => app_list}
  end

  get '/results/:name' do |name|
    app = app_list[name.to_sym]
    if app
      app.load_test_list = load_test_list
      app.app_id = name.to_sym
      erb :results_app_detail, :locals => {:app_detail => app}
    else
      status 404
      body "Not found"
    end
  end

  get '/results/:name/:test' do |name, test|
    #get result files from file under  files/apps/:name/results/:test/summary
    app = app_list[name.to_sym]
    if app and load_test_list.keys.include?(test.to_sym)
      app.result_set_list = Results::PastSummaryResults.new(name, test.chomp('_test')).overhead_test_results 
      app.result_set_list.each do |result|
        result.network_results = {}
        Results::PastNetworkResults.format_network(NetworkResult.new(CpuResultStrategy.new(name,test.chomp('_test'), result.id)).retrieve_average_results,:cpu,result.network_results)
        Results::PastNetworkResults.format_network(NetworkResult.new(KernelResultStrategy.new(name,test.chomp('_test'), result.id)).retrieve_average_results,:kernel,result.network_results)
        Results::PastNetworkResults.format_network(NetworkResult.new(MemorySwapResultStrategy.new(name,test.chomp('_test'), result.id)).retrieve_average_results,:memory_swap,result.network_results)
        Results::PastNetworkResults.format_network(NetworkResult.new(MemoryPageResultStrategy.new(name,test.chomp('_test'), result.id)).retrieve_average_results,:memory_page,result.network_results)
        Results::PastNetworkResults.format_network(NetworkResult.new(MemoryUtilizationResultStrategy.new(name,test.chomp('_test'), result.id)).retrieve_average_results,:memory_utilization,result.network_results)
        Results::PastNetworkResults.format_network(NetworkResult.new(TcpFailureNetworkResultStrategy.new(name,test.chomp('_test'), result.id)).retrieve_average_results,:tcp_failure,result.network_results)
        Results::PastNetworkResults.format_network(NetworkResult.new(TcpNetworkResultStrategy.new(name,test.chomp('_test'), result.id)).retrieve_average_results,:tcp,result.network_results)
        Results::PastNetworkResults.format_network(NetworkResult.new(IpFailureNetworkResultStrategy.new(name,test.chomp('_test'), result.id)).retrieve_average_results,:ip_failure,result.network_results)
        Results::PastNetworkResults.format_network(NetworkResult.new(IpNetworkResultStrategy.new(name,test.chomp('_test'), result.id)).retrieve_average_results,:ip,result.network_results)
        Results::PastNetworkResults.format_network(NetworkResult.new(DeviceNetworkResultStrategy.new(name,test.chomp('_test'), result.id)).retrieve_average_results,:ip,result.network_results)
      end
      app.test_type = test
      erb :results_app_test_detail, :locals => {:app_detail => app }
    else
      status 404
      body "Not found"
    end
  end

  post '/results/:name/:test' do |name, test|
    app = app_list[name.to_sym]
    if app and load_test_list.keys.include?(test.to_sym)
      app.compared_result_set_list = app.results.compared_test_results(params[:compare])
      erb :results_app_test_compare, :locals => {:app_detail => app }
    else
      status 404
    end
  end

  get '/results/:name/:test/metric/:metric' do |name, test, metric|
    #parse from previous result_set
    app = app_list[name.to_sym]
    results = []
    if app and load_test_list.keys.include?(test.to_sym)
      app.results = Results::PastSummaryResults.new(name, test.chomp('_test'))
      app.result_set_list = app.results.overhead_test_results 
      if app.result_set_list[0].respond_to?(metric.to_sym)
        app.result_set_list.each { |result| results << [result.date, result.send(metric.to_sym).to_f] }
      end
      content_type :json
    else
      status 404
    end
    body results.to_json
  end

  get '/results/:name/:test/id/:id/date/:date' do |name, test, id, date|
    #get result files from file under files/apps/:name/results/:test/:date
    app = app_list[name.to_sym]
    #group by then order by start time.  The first will always be repose
    begin
      if app and load_test_list.keys.include?(test.to_sym)
        app.results = Results::PastSummaryResults.new(name, test.chomp('_test'))
        app.detailed_results = app.results.detailed_results id
        app.date = date
        app.test_id = id
        app.test_type = test
        file_location = app.results.detailed_results_file_location(id)
        app.request_response_list = Models::Test.new.get_results_requests_by_file_location(file_location)
        app.config_list = Models::Configuration.new.get_by_result_file_location(file_location)
        app.test_location = Models::TestLocationFactory.get_by_file_location(file_location)
        erb :results_detail, :locals => {:app_detail => app}
      else
        status 404
      end
    rescue RuntimeError => e
      status 404
      body e.message
    end
  end

  get '/results/:name/:test/metric/:metric/id/:id/date/:date' do |name, test, metric, id, date|
    #get result files from file under files/apps/:name/results/:test/:date/:metric
    app = app_list[name.to_sym]
    begin
      if app and load_test_list.keys.include?(test.to_sym)
        app.results = Results::PastSummaryResults.new(name, test.chomp('_test'))
        app.detailed_results = app.results.detailed_results(id)
        repose_results = []
        origin_results = []
        if app.detailed_results[0][0].respond_to?(metric.to_sym)
          app.detailed_results[0].each { |result| repose_results << [result.date, result.send(metric.to_sym).to_f] }
        end
        if app.detailed_results[1][0].respond_to?(metric.to_sym)
          app.detailed_results[1].each { |result| origin_results << [result.date, result.send(metric.to_sym).to_f] }
        end
        results = { :repose => repose_results, :origin => origin_results }
        content_type :json
        body results.to_json
      else
        status 404
      end
    rescue RuntimeError => e
      status 404
      body e.message
    end
  end

  get '/results/:name/:test/:id/test_download/:file_name' do |name, test, id,file_name|
    app = app_list[name.to_sym]
    begin
      if app
        #get folder id
        app.results = Results::PastSummaryResults.new(name, test.chomp('_test'))
        app.detailed_results = app.results.detailed_results(id)
        file_location = app.results.detailed_results_file_location(id)
        downloaded_file = Models::TestLocationFactory.get_by_file_location(file_location).download
        p downloaded_file
        send_file downloaded_file, :filename => file_name, :type => 'Application/octet-stream'
      else
        status 404
      end
    rescue ArgumentError => e
      body e.message
      status 404
    rescue RuntimeError => r
      status 404
      body r.message
    end
  end
#end

#PerfApp.new
