require 'sinatra'
require 'json'
require 'logging'
require 'rbconfig'

require_relative './apps/bootstrap.rb'
require_relative './Models/models.rb'
require_relative './Models/perftest.rb'
require_relative './Models/test.rb'
require_relative './Models/configuration.rb'
require_relative './Models/testlocation.rb'
require_relative './Models/results.rb'

class PerfApp < Sinatra::Base

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


=begin
  load all plugins based on OS and application
  TODO: the plugin load will need to move down based on application desired.  Also each application will now have sub-apps to support repose's multiple client configurations vs. Atom Hopper single configuration
  bootstrap_config = Models::Bootstrap.new.config
  plugins = Models::Bootstrap.new.load_plugins
puts "plugins: #{plugins}"
  
  load_test_list = {
    :load_test => Models::PerfTest.new(1, 'Load Test', 'Test description'),
    :duration_test => Models::PerfTest.new(2, 'Duration Test','Test description'),
    :benchmark_test => Models::PerfTest.new(3, 'Benchmark Test','Test description'),
    :adhoc_test => Models::PerfTest.new(4, 'Adhoc Test','Test description')
  }
=end 

  results = nil

  # In your main application file
  configure do
    set :views, "#{File.dirname(__FILE__)}/views"
    set :public_dir, "#{File.dirname(__FILE__)}/public"
    enable :show_exceptions
  end

  get '/' do
    erb :index, :locals => {
      :data => Apps::Bootstrap.application_list
    }    
  end
  
  get '/:application' do |application|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new
      erb :app_index, :locals => {
        :data => {
          :name => new_app.config['application']['name'], 
          :description => new_app.config['application']['description'],
          :title => new_app.config['application']['name'],
          :application => app[:id]
        }
      }
    else
      status 404
    end
  end

  get '/:application/applications' do |application|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new
      erb :applications, :locals => {
        :application_list => new_app.config['application']['sub_apps'],
        :title => new_app.config['application']['name'],
        :application => app[:id]
      }
    else
      status 404
    end
  end

  get '/:application/applications/:name' do |application, name|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app 
      new_app = app[:klass].new
      sub_app = new_app.config['application']['sub_apps'].find {|k, v| v['id'] == name}
      if sub_app
        #app[:config_list] = Models::Configuration.new.get_by_name(name)
        #app[:test_location] = Models::TestLocationFactory.get_by_name(name)
        erb :app_detail, :locals => {
          :application => app[:id],
          :sub_app_id => name.to_sym,
          :title => new_app.config['application']['name'],
          :request_response_list => Models::Test.new(new_app.db).get_setup_requests_by_name(app[:id], name),
          :config_list => Models::Configuration.new(new_app.db).get_by_name(app[:id], name),
          :test_location => Models::TestLocation.new('t','y','x')
        }
      else
        status 404
      end
    else
      status 404
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

  get '/:application/tests' do |application|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new
      erb :tests, :locals => {
        :application_list => new_app.config['application']['sub_apps'],
        :title => new_app.config['application']['name'],
        :application => app[:id]
      }
    else
      status 404
    end
  end

  get '/tests/:name' do |name|
    app = bootstrap_config['applications'].find { |k,v| k['id'] == name }
    if app
      app[:load_test_list] = load_test_list
      app[:app_id] = name.to_sym
      app[:title] = bootstrap_config['name']
      erb :tests_list, :locals => {:app_detail => app}
    else
      status 404
      body "Not found"
    end
  end

=begin
  loop through plugins here
=end
  get '/tests/:name/:test' do |name, test|
    app = bootstrap_config['applications'].find { |k,v| k['id'] == name }
    if app and load_test_list.keys.include?(test.to_sym)
      app[:results] = Results::LiveSummaryResults.start_running_results(name, test.chomp('_test'))
      app[:result_set_list] = app[:results].summary_results 
      app[:test_type] = test
      app[:app_id] = name.to_sym
      app[:title] = bootstrap_config['name']
      erb :tests_app_test_detail, :locals => {:app_detail => app }
    else
      status 404
      body "Not found"
    end
  end

  get '/tests/:name/:test/metric/:metric' do |name, test, metric|
    #parse from summary file and jmx filei
    app = bootstrap_config['applications'].find { |k,v| k['id'] == name }
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
    app = bootstrap_config['applications'].find { |k,v| k['id'] == name }
    if app and load_test_list.keys.include?(test.to_sym) and !app[:results].test_ended
      temp_results = []
      if app[:results] && app[:results].summary_results[0].respond_to?(metric.to_sym)
        app[:results].new_summary_values.each { |result| temp_results << [result.date, result.send(metric.to_sym).to_f] }
      end
      content_type :json
      response = { :results => temp_results, :ended => app[:results].test_ended}
    else
      status 404
      response = { :results => [], :ended => true}
    end
    body response.to_json
  end

  get '/results' do
    erb :results, :locals => {
      :application_list => bootstrap_config['applications'],
      :title => bootstrap_config['name']
    }
  end

  get '/results/:name' do |name|
    app = bootstrap_config['applications'].find { |k,v| k['id'] == name }
    if app
      app[:load_test_list] = load_test_list
      app[:app_id] = name.to_sym
      app[:title] = bootstrap_config['name']
      erb :results_list, :locals => {:app_detail => app}
    else
      status 404
      body "Not found"
    end
  end

  get '/results/:name/:test' do |name, test|
    #get result files from file under  files/apps/:name/results/:test/summary
    app = bootstrap_config['applications'].find { |k,v| k['id'] == name }
    if app and load_test_list.keys.include?(test.to_sym)
      if bootstrap_config['app_type'] == 'OVERHEAD'
        app[:result_set_list] = Results::PastSummaryResults.new(name, test.chomp('_test')).overhead_test_results 
      else
        app[:result_set_list] = Results::PastSummaryResults.new(name, test.chomp('_test')) 
      end
      app[:plugin_list] = []
      plugins.each {|p| app[:plugin_list] << {:id => p.to_s, :data => p.show_plugin_names.map {|id| {:id => id[:id], :name => id[:name] } } } }
      app[:result_set_list].each do |result|
        
=begin
  
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
=end
      end
      app[:test_type] = test
      app[:app_id] = name
      app[:title] = bootstrap_config['name']
      erb :results_app_test_detail, :locals => {:app_detail => app }
    else
      status 404
      body "Not found"
    end
  end

  post '/results/:name/:test' do |name, test|
    app = bootstrap_config['applications'].find { |k,v| k['id'] == name }
    if app and load_test_list.keys.include?(test.to_sym)
      app[:results] = Results::PastSummaryResults.new(name, test.chomp('_test')) 
      app[:compared_result_set_list] = app[:results].compared_test_results(params[:compare])
      app[:test_type] = test
      app[:app_id] = name
      app[:title] = bootstrap_config['name']
      erb :results_app_test_compare, :locals => {:app_detail => app }
    else
      status 404
    end
  end

  get '/results/:name/:test/id/:id/plugin/:plugin/:option' do |name, test, id, plugin, option|
    #get average results for plugin
    #get detailed results for plugin to graph
    app = bootstrap_config['applications'].find { |k,v| k['id'] == name }
    if app and load_test_list.keys.include?(test.to_sym)
      plugin_instance = plugins.find {|p| p.to_s == plugin }
      app[:summary_plugin_data] = plugin_instance.new.show_summary_data(name, test, option, id)
      detailed_plugin_data = plugin_instance.new.show_detailed_data(name, test, option, id)
      detailed_plugin_result = {}
      detailed_plugin_data.each do |key, value|
        detailed_plugin_result[key] = {}
        detailed_plugin_result[key][:headers] = value[:headers]
        detailed_plugin_result[key][:content] = {}
        detailed_plugin_result[key][:description] = value[:description]
        value[:content].each do |instance, data|
          detailed_plugin_result[key][:content][instance] = plugin_instance.new.order_by_date(value[:content][instance])
        end  
      end

      app[:detailed_plugin_data] = detailed_plugin_result
      app[:detailed_unordered_plugin_data] = detailed_plugin_data
      app[:test_type] = test
      app[:app_id] = name
      app[:title] = bootstrap_config['name']
      app[:plugin_name] = plugin
      app[:option] = option
      erb :results_plugin, :locals => {:app_detail => app }
    else
      status 404
    end
  end

  get '/results/:name/:test/metric/:metric/compare/:ids' do |name, test, metric, ids|
    #get result files from file under files/apps/:name/results/:test/:date/:metric
    app = bootstrap_config['applications'].find { |k,v| k['id'] == name }
    id_list = ids.split(",")
    begin
      if app and load_test_list.keys.include?(test.to_sym)
        app[:results] = Results::PastSummaryResults.new(name, test.chomp('_test')) 
        @results = {} unless @results
        id_list.each do |id|
          @results[id] = Array.new
          detailed_results = app[:results].detailed_results(id)
          if detailed_results[0][0].respond_to?(metric.to_sym)
            detailed_results[0].each { |result| @results[id] << [result.date, result.send(metric.to_sym).to_f] }
          end
        end

        results = { :compare_one => @results[id_list[0]], :compare_two => @results[id_list[1]] }
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

  get '/results/:name/:test/metric/:metric' do |name, test, metric|
    #parse from previous result_set
    app = bootstrap_config['applications'].find { |k,v| k['id'] == name }
    results = {} unless results
    results[metric.to_sym] = []
    if app and load_test_list.keys.include?(test.to_sym)
      if bootstrap_config['app_type'] == 'OVERHEAD'
        app[:result_set_list] = Results::PastSummaryResults.new(name, test.chomp('_test')).overhead_test_results 
      else
        app[:result_set_list] = Results::PastSummaryResults.new(name, test.chomp('_test')) 
      end
      if app[:result_set_list][0].respond_to?(metric.to_sym)
        app[:result_set_list].each { |result| results[metric.to_sym] << [result.date, result.send(metric.to_sym).to_f] }
      end
      content_type :json
    else
      status 404
    end
    body results.to_json
  end

  get '/results/:name/:test/id/:id/date/:date' do |name, test, id, date|
    #get result files from file under files/apps/:name/results/:test/:date
    app = bootstrap_config['applications'].find { |k,v| k['id'] == name }
    #group by then order by start time.  The first will always be repose
    begin
      if app and load_test_list.keys.include?(test.to_sym)
        app[:results] = Results::PastSummaryResults.new(name, test.chomp('_test'))
        app[:detailed_results] = app[:results].detailed_results id
        app[:date] = date
        app[:test_id] = id
        app[:test_type] = test
        file_location = app[:results].detailed_results_file_location(id)
        app[:request_response_list] = Models::Test.new.get_results_requests_by_file_location(file_location)
        app[:config_list] = Models::Configuration.new.get_by_result_file_location(file_location)
        app[:test_location] = Models::TestLocationFactory.get_by_file_location(file_location)
        app[:title] = bootstrap_config['name']
        erb :results_instance_detail, :locals => {:app_detail => app}
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
    app = bootstrap_config['applications'].find { |k,v| k['id'] == name }
    begin
      if app and load_test_list.keys.include?(test.to_sym)
        app[:results] = Results::PastSummaryResults.new(name, test.chomp('_test'))
        app[:detailed_results] = app[:results].detailed_results(id)
        repose_results = []
        origin_results = []
        if app[:detailed_results][0][0].respond_to?(metric.to_sym)
          app[:detailed_results][0].each { |result| repose_results << [result.date, result.send(metric.to_sym).to_f] }
        end
        if app[:detailed_results][1][0].respond_to?(metric.to_sym)
          app[:detailed_results][1].each { |result| origin_results << [result.date, result.send(metric.to_sym).to_f] }
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
end

#PerfApp.new
