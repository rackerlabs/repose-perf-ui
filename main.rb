require 'sinatra'
require 'json'
require 'logging'
require 'rbconfig'
require 'open-uri'

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

  results = nil

  # In your main application file
  configure do
    set :views, "#{File.dirname(__FILE__)}/views"
    set :public_dir, "#{File.dirname(__FILE__)}/public"
    enable :show_exceptions if development?
    set :deployment, environment
    Apps::Bootstrap.main_config(environment)
  end
  
  configure :development do
    set :show_exceptions, :after_handler
  end
  
  error ArgumentError do
    request.env['sinatra.error'].message
  end
  
  error OpenURI::HTTPError do
    "Unable to gather required data.  There's a misconfiguration to connect to backend services."
  end

  get '/' do
    erb :index, :locals => {
      :data => Apps::Bootstrap.application_list
    }    
  end
  
  get '/:application' do |application|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
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
      new_app = app[:klass].new(settings.deployment)
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
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        erb :app_detail, :locals => {
          :application => app[:id],
          :sub_app_id => name.to_sym,
          :title => new_app.config['application']['name'],
          :request_response_list => Models::Test.new(new_app.db).get_setup_requests_by_name(app[:id], name),
          :config_list => Models::Configuration.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name),
          :test_location => Models::TestLocationFactory.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name)
        }
      else
        status 404
      end
    else
      status 404
    end
  end

  get '/:application/applications/:name/test_download/:file_name' do |application, name, file_name|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app 
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        begin 
          downloaded_file =  Models::TestLocationFactory.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name).download
          attachment "test_file"
          content_type = 'Application/octet-stream'
          body downloaded_file
        rescue ArgumentError => e
          status 404
          body e.message
        end
      else
        status 404
        body "No test script exists for #{application}/#{name}"
      end
    else
      status 404
      body "No test script exists for #{application}/#{name}"
    end
  end

  get '/:application/results' do |application|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      erb :results, :locals => {
        :application_list => new_app.config['application']['sub_apps'],
        :title => new_app.config['application']['name'],
        :application => app[:id]
      }
    else
      status 404
    end
  end

  get '/:application/results/:name' do |application, name|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app 
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        erb :results_list, :locals => {
          :application => app[:id],
          :sub_app_id => name.to_sym,
          :title => new_app.config['application']['name'],
          :load_test_list => Apps::Bootstrap.test_list
        }
      else
        status 404
      end
    else
      status 404
    end
  end

  get '/:application/results/:name/:test' do |application, name, test|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and Apps::Bootstrap.test_list.keys.include?(test) 
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        results = Results::PastSummaryResults.new(application, name, 
            new_app.config['application']['type'].to_sym, test.chomp('_test'), 
            new_app.db, new_app.fs_ip, nil, logger)
        plugins = []
        new_app.load_plugins.each do |p| 
          plugins << {:id => p.to_s, :data => p.show_plugin_names.map do |id| 
            {:id => id[:id], :name => id[:name] } 
          end 
          } 
        end
        
        erb results.summary_view, :locals => {
          :application => app[:id],
          :sub_app_id => name.to_sym,
          :title => new_app.config['application']['name'],
          :result_set_list => results.past_summary_results.test_results(new_app.db, new_app.fs_ip, results.test_list),
          :plugin_list => plugins,
          :test_type => test
        }
      else
        status 404
      end
    else
      status 404
    end
  end

  get '/:application/results/:name/:test/metric/:metric' do |application, name, test, metric|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and Apps::Bootstrap.test_list.keys.include?(test) 
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        metric_results = {} unless metric_results
        metric_results[metric.to_sym] = []
        results = Results::PastSummaryResults.new(application, name, 
            new_app.config['application']['type'].to_sym, test.chomp('_test'), 
            new_app.db, new_app.fs_ip, nil, logger)
        result_set_list = results.past_summary_results.test_results(new_app.db, new_app.fs_ip, results.test_list)
        if result_set_list[0].respond_to?(metric.to_sym)
          result_set_list.each { |result| metric_results[metric.to_sym] << [result.start, result.send(metric.to_sym).to_f] }
        else
          halt 404, {'Content-Type' => 'application/json'},  {'fail' => 'invalid metric specified'}.to_json
        end
      else 
        halt 404, {'Content-Type' => 'application/json'},  {'fail' => 'invalid sub app specified'}.to_json
      end
    else
      halt 404, {'Content-Type' => 'application/json'},  {'fail' => 'invalid application specified'}.to_json
    end  
    content_type :json
    body metric_results.to_json
  end

  get '/:application/results/:name/:test/metric/:metric/id/:id' do |application, name, test, metric, id|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and Apps::Bootstrap.test_list.keys.include?(test) 
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        results = Results::PastSummaryResults.new(application, name, 
            new_app.config['application']['type'].to_sym, test.chomp('_test'), 
            new_app.db, new_app.fs_ip, nil, logger)
        detailed_results = results.past_summary_results.detailed_results(new_app.db, new_app.fs_ip, results.test_list, id)
        metric_results = results.past_summary_results.metric_results(detailed_results, metric)
        if metric_results and metric_results.length > 0
          content_type :json
          json_results = { metric.to_sym => metric_results }
          body json_results.to_json
        else
          halt 404, {'Content-Type' => 'application/json'},  {'fail' => 'The metric data is empty'}.to_json
        end
      else 
        halt 404, {'Content-Type' => 'application/json'},  {'fail' => 'invalid sub app specified'}.to_json
      end
    else
      halt 404, {'Content-Type' => 'application/json'},  {'fail' => 'invalid application specified'}.to_json
    end  
  end

  get '/:application/results/:name/:test/id/:id' do |application, name, test, id|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and Apps::Bootstrap.test_list.keys.include?(test) 
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        app_type = new_app.config['application']['type'].to_sym        
        results = Results::PastSummaryResults.new(application, name, 
            app_type, test.chomp('_test'), 
            new_app.db, new_app.fs_ip, nil, logger)
        detailed_results = results.past_summary_results.detailed_results(new_app.db, new_app.fs_ip, results.test_list, id)
        if detailed_results and detailed_results.length > 0
          test_id = id
          test_type = test
          erb results.detailed_view, :locals => {
            :application => app[:id],
            :sub_app_id => name.to_sym,
            :title => new_app.config['application']['name'],
            :result_set_list => detailed_results,
            :test_id => id,
            :test_type => test,
            :request_response_list => Models::Test.new(new_app.db).get_result_requests(app_type, application, name, test.chomp('_test'), id),
            :config_list => Models::Configuration.new(new_app.db, new_app.fs_ip).get_result(app_type, application, name, test.chomp('_test'), id),
            :test_location => Models::TestLocationFactory.new(new_app.db, new_app.fs_ip).get_result(app_type, application, name, test.chomp('_test'), id)
          }
        else
          status 404
        end
      else
        status 404
      end
    else
      status 404
    end  
  end
  
  get '/:application/results/:name/:test/id/:id/plugin/:plugin/:option' do |application, name, test, id, plugin, option|
    #get average results for plugin
    #get detailed results for plugin to graph
    #TODO: modify the plugin show summary/detailed/order data to retrieve from specific areas the plugin's allowed to retrieve from (this may be different than the regular data store but is not recommended)
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and Apps::Bootstrap.test_list.keys.include?(test) 
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        plugin_instance = plugins.find {|p| p.to_s == plugin }
=begin
  get summary data.  Pass in new_app, application, name, test type, plugin name, option of the plugin (strategy)
=end
        summary_plugin_data = plugin_instance.new.show_summary_data(new_app, application, name, test, option, id)
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
        #TODO: replace data with valid data
        erb Apps::Bootstrap.initialize_results[application_type.to_sym][:plugin_view], :locals => {
          :application => app[:id],
          :sub_app_id => name.to_sym,
          :title => new_app.config['application']['name'],
          :summary_plugin_data => nil,
          :detailed_plugin_data => nil,
          :detailed_unordered_plugin_data => nil,
          :test_type => test,
          :plugin_name => plugin,
          :option => option
        }
      else
        status 404
      end
    else
      status 404
    end
  end

  get '/:application/results/:name/:test/metric/:metric/compare/:ids' do |application, name, test, metric, ids|
    #get result files from file under files/apps/:name/results/:test/:date/:metric
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and Apps::Bootstrap.test_list.keys.include?(test) 
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        results = Results::PastSummaryResults.new(application, name, 
            :comparison, test.chomp('_test'), 
            new_app.db, new_app.fs_ip, nil, logger)
        detailed_results = results.past_summary_results.detailed_results(new_app.db, new_app.fs_ip, results.test_list, ids)
        metric_results = results.past_summary_results.metric_results(detailed_results, metric)
        if metric_results and metric_results.length > 0
          content_type :json
          json_results = { metric.to_sym => metric_results }
          body json_results.to_json
        else
          halt 404, {'Content-Type' => 'application/json'},  {'fail' => 'The metric data is empty'}.to_json
        end
      else 
        halt 404, {'Content-Type' => 'application/json'},  {'fail' => 'invalid sub app specified'}.to_json
      end
    else
      halt 404, {'Content-Type' => 'application/json'},  {'fail' => 'invalid application specified'}.to_json
    end  
  end

  get '/:application/results/:name/:test/:id/test_download/:file_name' do |application, name, test, id,file_name|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and Apps::Bootstrap.test_list.keys.include?(test) 
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        begin
          downloaded_file =  Models::TestLocationFactory.new(new_app.db, new_app.fs_ip).get_result_by_id(
            application, name, test.chomp('_test'), id).download
          attachment "test_file"
          content_type = 'Application/octet-stream'
          body downloaded_file
        rescue 
          halt 404, "No test script exists for #{application}/#{name}/#{id}"
        end
      else
        halt 404, "No test script exists for #{application}/#{name}"
      end
    else
      halt 404, "No test script exists for #{application}/#{name}"
    end
  end

  post '/:application/results/:name/:test' do |application, name, test|
    halt 400, "No tests were specified for comparison" unless params[:compare]
    comparison_id_list = params[:compare]
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and Apps::Bootstrap.test_list.keys.include?(test) 
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        results = Results::PastSummaryResults.new(application, name, 
            new_app.config['application']['type'].to_sym, test.chomp('_test'), 
            new_app.db, new_app.fs_ip, nil, logger)
        result_set_list = results.past_summary_results.test_results(new_app.db, new_app.fs_ip, results.test_list)
        plugins = []
        new_app.load_plugins.each do |p| 
          plugins << {:id => p.to_s, :data => p.show_plugin_names.map do |id| 
            {:id => id[:id], :name => id[:name] } 
          end 
          } 
        end
        
        erb :results_app_test_compare, :locals => {
          :application => app[:id],
          :sub_app_id => name.to_sym,
          :title => new_app.config['application']['name'],
          :result_set_list => result_set_list.find_all {|result| comparison_id_list.include?(result.id) },
          :plugin_list => plugins,
          :test_type => test
        }
      else
        halt 404, "No sub application for #{name} found"
      end
    else
      halt 404, "No application by name of #{application}/#{test} found"
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

  get '/:application/tests/:name' do |application, name|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app 
      new_app = app[:klass].new
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        erb :tests_list, :locals => {
          :application => app[:id],
          :sub_app_id => name.to_sym,
          :title => new_app.config['application']['name'],
          :load_test_list => Apps::Bootstrap.test_list
        }
      else
        status 404
      end
    else
      status 404
    end
  end

=begin
  loop through plugins here
=end
  get '/:application/tests/:name/:test' do |application, name, test|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app 
      new_app = app[:klass].new
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        erb :tests_app_test_detail, :locals => {
          :application => app[:id],
          :sub_app_id => name.to_sym,
          :title => new_app.config['application']['name'],
          :results => Results::LiveSummaryResults.start_running_results(name, test.chomp('_test')),
          :result_set_list => Results::LiveSummaryResults.start_running_results(name, test.chomp('_test')).summary_results
        }
      else
        status 404
      end
    else
      status 404
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
  
  post '/:application/applications/:name/:test/start' do |application, name, test|
=begin
  POST /atom_hopper/applications/main/load/start -d '{"length":60, "description": "this is a description of the test", "flavor_type": "performance", "release": 1.6}'
=end    
  end
  
  get '/:application/applications/:name/:test/stop' do |application, name, test|
=begin
  GET /atom_hopper/application/main/load/stop/id
=end    
  end
end

#PerfApp.new
