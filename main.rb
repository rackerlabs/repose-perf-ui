require 'sinatra'
require 'json'
require 'logging'
require 'rbconfig'
require 'open-uri'

require_relative './apps/bootstrap.rb'
require_relative './Models/models.rb'
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
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and Apps::Bootstrap.test_list.keys.include?(test) 
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        plugin_instance = new_app.load_plugins.find {|p| p.to_s == plugin } 
        summary_plugin_data = plugin_instance.new(new_app.db, new_app.fs_ip).show_summary_data(application, name, test, option, id)
        detailed_plugin_data = plugin_instance.new(new_app.db, new_app.fs_ip).show_detailed_data(application, name, test, option, id)
        if summary_plugin_data and detailed_plugin_data
          detailed_plugin_result = {}
          detailed_plugin_data.each do |key, value|
            detailed_plugin_result[key] = {}
            detailed_plugin_result[key][:headers] = value[:headers]
            detailed_plugin_result[key][:content] = {}
            detailed_plugin_result[key][:description] = value[:description]
            value[:content].each do |instance, data|
              detailed_plugin_result[key][:content][instance] = plugin_instance.new(new_app.db, new_app.fs_ip).order_by_date(value[:content][instance])
            end  
          end
    
          erb Apps::Bootstrap.initialize_results[new_app.config['application']['type'].to_sym][:plugin_view], :locals => {
            :application => app[:id],
            :sub_app_id => name.to_sym,
            :title => new_app.config['application']['name'],
            :summary_plugin_data => summary_plugin_data,
            :detailed_plugin_data => detailed_plugin_result,
            :detailed_unordered_plugin_data => detailed_plugin_data,
            :test_id => id,
            :test_type => test,
            :plugin_name => plugin,
            :option => option
          }
        else
          halt 404, "no metric data found for #{application}/#{name}/#{test}/#{id}/#{plugin}/#{option}"
        end
      else
        halt 404, "No sub application for #{name} found"
      end
    else
      halt 404, "No application by name of #{application}/#{test} found"
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
          :test_type => test,
          :compare_guids => params[:compare]
        }
      else
        halt 404, "No sub application for #{name} found"
      end
    else
      halt 404, "No application by name of #{application}/#{test} found"
    end
  end
  
  post '/:application/results/:name/:test/compare-plugin/metric' do |application, name, test|
    halt 400, "No tests were specified for comparison" unless params[:compare]
    halt 400, "No plugin was specified for comparison" unless params[:plugin]
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and Apps::Bootstrap.test_list.keys.include?(test) 
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        comparison_id_list = params[:compare].split(',')
        plugin_id = params[:plugin]
        plugin_id_data = plugin_id.split('|||')
        plugin = plugin_id_data[0]
        option = plugin_id_data[1]
        plugin_instance = new_app.load_plugins.find {|p| p.to_s == plugin }
        halt 404, {'Content-Type' => 'application/json'},  {'fail' => "No plugin by name of #{plugin} found"}.to_json unless plugin_instance 
        detailed_plugin_data_list = [] 
        valid_comparison_id_list = []
        comparison_id_list.each do |id| 
          detailed_plugin_data = plugin_instance.new(new_app.db, new_app.fs_ip).show_detailed_data(application, name, test, option, id)
          if detailed_plugin_data and detailed_plugin_data[option.to_sym][:content].length > 0   
            detailed_plugin_data_list << {
              :id => id, 
              :data => detailed_plugin_data
            }
            valid_comparison_id_list << id
          end
        end
        if detailed_plugin_data_list and valid_comparison_id_list.length > 0
          content_type :json
          body detailed_plugin_data_list.to_json    
        else
          halt 404, {'Content-Type' => 'application/json'},  {'fail' => "no data for #{plugin_id} found"}.to_json
        end
      else
        halt 404, {'Content-Type' => 'application/json'},  {'fail' => "No sub application for #{name} found"}.to_json
      end
    else
      halt 404, {'Content-Type' => 'application/json'},  {'fail' => "No application by name of #{application}/#{test} found"}.to_json
    end    
    
  end
  
  post '/:application/results/:name/:test/compare-plugin' do |application, name, test|
    halt 400, "No tests were specified for comparison" unless params[:compare]
    halt 400, "No plugin was specified for comparison" unless params[:plugin_id]
    comparison_id_list = params[:compare].split('+')
    plugin_id = params[:plugin_id]

    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and Apps::Bootstrap.test_list.keys.include?(test) 
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        #get plugin_summary_results for each data set
        plugin_id_data = plugin_id.split('|||')
        plugin = plugin_id_data[0]
        option = plugin_id_data[1]
        plugin_instance = new_app.load_plugins.find {|p| p.to_s == plugin }
        halt 404, "No plugin by name of #{plugin} found" unless plugin_instance
        summary_plugin_data_list = [] 
        valid_comparison_id_list = []
        comparison_id_list.each do |id| 
          summary_plugin_data = plugin_instance.new(new_app.db, new_app.fs_ip).show_summary_data(application, name, test, option, id)
          if summary_plugin_data and summary_plugin_data[option.to_sym][:content].length > 0   
            summary_plugin_data_list << {
              :id => id, 
              :data => summary_plugin_data
            }
            valid_comparison_id_list << id
          end
        end
        
        #detailed_plugin_data = plugin_instance.new(new_app.db, new_app.fs_ip).show_detailed_data(application, name, test, option, id)
        if summary_plugin_data_list and valid_comparison_id_list.length > 0
          erb :results_plugin_test_compare, :locals => {
            :application => app[:id],
            :sub_app_id => name.to_sym,
            :title => new_app.config['application']['name'],
            :summary_plugin_data_list => summary_plugin_data_list,
            :test_type => test,
            :compare_guids => valid_comparison_id_list,
            :plugin_name => plugin,
            :plugin_id => plugin_id,
            :option => option
          }
        else
          halt 404, "No data for #{plugin_id} found"
        end
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
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and Apps::Bootstrap.test_list.keys.include?(test) 
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        request.body.rewind
        json_data = JSON.parse(request.body.read)
        content_type :json
        halt 400, { "fail" => "required keys are missing"}.to_json unless json_data.has_key?("name") and json_data.has_key?("length") and json_data.has_key?("runner")
        guid_response = new_app.start_test_recording(application, name, test.chomp('_test'), json_data)
        halt 400, {'Content-Type' => 'application/json'}, {'fail' => 'test for atom_hopper/main/load_test already started'}.to_json if guid_response.length == 0
        halt 400, {'Content-Type' => 'application/json'}, guid_response if JSON.parse(guid_response).has_key?("fail")
        body guid_response
      end
    end
  end
  
  post '/:application/applications/:name/:test/stop' do |application, name, test|
=begin
  post /atom_hopper/application/main/load/stop
  {
    'guid':'1234-6382-2938-2938-2933',
    'servers':{
      'config':{
        'server':'<server>',
        'path':'<file path>'
      },
      'results':{
        'server':'<server>',
        'path':'<file path>'
      }        
    }
  }
=end    
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and Apps::Bootstrap.test_list.keys.include?(test) 
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        request.body.rewind
        json_data = JSON.parse(request.body.read)
        content_type :json
        halt 400, { "fail" => "required keys are missing"}.to_json unless json_data.has_key?("guid")
        stop_response = new_app.stop_test_recording(application, name, test.chomp('_test'), json_data)
        halt 400, {'Content-Type' => 'application/json'}, stop_response.to_json if stop_response.has_key?("fail")
        body stop_response.to_json
      else 
        halt 404, {'Content-Type' => 'application/json'},  {'fail' => 'invalid sub app specified'}.to_json
      end
    else
      halt 404, {'Content-Type' => 'application/json'},  {'fail' => 'invalid application specified'}.to_json
    end  
  end
end

#PerfApp.new
