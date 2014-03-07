require 'rubygems'
require 'sinatra'
require 'json'
require 'rbconfig'
require 'open-uri'

require_relative 'apps/bootstrap.rb'
require_relative 'Models/models.rb'

module SnapshotComparer
class PerfApp < Sinatra::Base
  results = nil

  # In your main application file
  configure do
    set :views, "#{File.dirname(__FILE__)}/views"
    set :public_dir, "#{File.dirname(__FILE__)}/public"
    enable :show_exceptions if development? #or test?
    set :deployment, environment
    SnapshotComparer::Apps::Bootstrap.main_config(environment)
  end

  configure :development do
    set :show_exceptions, :after_handler
    enable :logging
  end

  error ArgumentError do
    request.env['sinatra.error'].message
  end

  error OpenURI::HTTPError do
    "Unable to gather required data.  There's a misconfiguration to connect to backend services."
  end

  get '/' do
    erb :index, :locals => {
      :data => SnapshotComparer::Apps::Bootstrap.application_list
    }
  end

  get '/:application' do |application|
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
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
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
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
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
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
          :test_location_list => Models::TestLocationFactory.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name)
        }
      else
        status 404
      end
    else
      status 404
    end
  end

  get '/:application/applications/:name/update' do |application, name|
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        erb :app_detail_update, :locals => {
          :application => app[:id],
          :sub_app_id => name.to_sym,
          :title => new_app.config['application']['name'],
          :request_response_list => Models::Test.new(new_app.db).get_setup_requests_by_name(app[:id], name),
          :config_list => Models::Configuration.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name),
          :test_location_list => Models::TestLocationFactory.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name),
          :test_type_list => SnapshotComparer::Apps::Bootstrap.test_list.map {|k, v| {:id => k, :name => v["name"] } },
          :runner_list => SnapshotComparer::Apps::Bootstrap.runner_list.map { |k, _| k }
        }
      else
        status 404
      end
    else
      status 404
    end
  end

  post '/:application/applications/:name/add_request_response' do |application, name|
    halt 400, "No request specified" unless params['request']
    halt 400, "No response specified" unless params['response']
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        begin
          Models::Test.new(new_app.db).add_request_response(application, name, new_app.storage_info, params['request'], params['response'])
          status 201
          erb :app_detail_update, :locals => {
            :application => app[:id],
            :sub_app_id => name.to_sym,
            :title => new_app.config['application']['name'],
            :request_response_list => Models::Test.new(new_app.db).get_setup_requests_by_name(app[:id], name),
            :config_list => Models::Configuration.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name),
            :test_location_list => Models::TestLocationFactory.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name),
            :test_type_list => SnapshotComparer::Apps::Bootstrap.test_list.map {|k, v| {:id => k, :name => v["name"] } },
            :runner_list => SnapshotComparer::Apps::Bootstrap.runner_list.map { |k, _| k }
          }
        rescue ArgumentError => e
          halt 404, 'invalid request response'
        end
      else
        halt 404, 'invalid sub app specified'
      end
    else
      halt 404, 'invalid application specified'
    end
  end

  post '/:application/applications/:name/update_request_response' do |application, name|
    halt 400, "No request specified" unless params['request'] || params['request']['request_id']
    halt 400, "No response specified" unless params['response'] || params['response']['request_id']
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        begin
          Models::Test.new(new_app.db).update_request_response(application, name, new_app.storage_info, params['request'], params['response'])
          status 200
        rescue ArgumentError => e
          halt 404, 'invalid request response'
        end
      else
        halt 404, 'invalid sub app specified'
      end
    else
      halt 404, 'invalid application specified'
    end
  end

  delete '/:application/applications/:name/remove_request_response/:requests_to_delete' do |application, name,requests_to_delete|
    request_ids = requests_to_delete.split(',')
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        begin
          Models::Test.new(new_app.db).remove_request_response(application, name, new_app.storage_info, request_ids)
          status 200
          erb :app_detail_update, :locals => {
            :application => app[:id],
            :sub_app_id => name.to_sym,
            :title => new_app.config['application']['name'],
            :request_response_list => Models::Test.new(new_app.db).get_setup_requests_by_name(app[:id], name),
            :config_list => Models::Configuration.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name),
            :test_location_list => Models::TestLocationFactory.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name),
            :test_type_list => SnapshotComparer::Apps::Bootstrap.test_list.map {|k, v| {:id => k, :name => v["name"] } },
            :runner_list => SnapshotComparer::Apps::Bootstrap.runner_list.map { |k, _| k }
          }
        rescue ArgumentError => e
          halt 404, 'invalid request ids specified'
        end
      else
        halt 404, 'invalid sub app specified'
      end
    else
      halt 404, 'invalid application specified'
    end
  end

  post '/:application/applications/:name/upload_config' do |application, name|
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        begin
          config_name = params['upload_config'][:filename]
          config_body = params['upload_config'][:tempfile]
          Models::Configuration.new(new_app.db, new_app.fs_ip).add_config(application, name, new_app.storage_info, config_name, config_body)
          status 201
          erb :app_detail_update, :locals => {
            :application => app[:id],
            :sub_app_id => name.to_sym,
            :title => new_app.config['application']['name'],
            :request_response_list => Models::Test.new(new_app.db).get_setup_requests_by_name(app[:id], name),
            :config_list => Models::Configuration.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name),
            :test_location_list => Models::TestLocationFactory.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name),
            :test_type_list => SnapshotComparer::Apps::Bootstrap.test_list.map {|k, v| {:id => k, :name => v["name"] } },
            :runner_list => SnapshotComparer::Apps::Bootstrap.runner_list.map { |k, _| k }
          }
        rescue ArgumentError => e
          halt 404, 'invalid config file specified'
        end
      else
        halt 404, 'invalid sub app specified'
      end
    else
      halt 404, 'invalid application specified'
    end
  end

  post '/:application/applications/:name/upload_test_file' do |application, name|
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        begin
          test_file_name = params['upload_test_file'][:filename]
          test_file_body = params['upload_test_file'][:tempfile]
          test_file_runner = params['test_file_runner']
          test_file_type = params['test_file_type']
          Models::TestLocationFactory.new(new_app.db, new_app.fs_ip).add_test_file(application, name, new_app.storage_info, test_file_name, test_file_body, test_file_runner, test_file_type)
          status 201
          erb :app_detail_update, :locals => {
            :application => app[:id],
            :sub_app_id => name.to_sym,
            :title => new_app.config['application']['name'],
            :request_response_list => Models::Test.new(new_app.db).get_setup_requests_by_name(app[:id], name),
            :config_list => Models::Configuration.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name),
            :test_location_list => Models::TestLocationFactory.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name),
            :test_type_list => SnapshotComparer::Apps::Bootstrap.test_list.map {|k, v| {:id => k, :name => v["name"] } },
            :runner_list => SnapshotComparer::Apps::Bootstrap.runner_list.map { |k, _| k }
          }
        rescue ArgumentError => e
          halt 404, 'invalid config file specified'
        end
      else
        halt 404, 'invalid sub app specified'
      end
    else
      halt 404, 'invalid application specified'
    end
  end

  post '/:application/applications/:name/remove_config' do |application, name|
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        begin
          config_list = params['remove_config']
          config_list.each do |config_name|
            Models::Configuration.new(new_app.db, new_app.fs_ip).remove_config(application, name, new_app.storage_info, config_name)
          end
          status 200
          erb :app_detail_update, :locals => {
            :application => app[:id],
            :sub_app_id => name.to_sym,
            :title => new_app.config['application']['name'],
            :request_response_list => Models::Test.new(new_app.db).get_setup_requests_by_name(app[:id], name),
            :config_list => Models::Configuration.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name),
            :test_location_list => Models::TestLocationFactory.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name),
            :test_type_list => SnapshotComparer::Apps::Bootstrap.test_list.map {|k, v| {:id => k, :name => v["name"] } },
            :runner_list => SnapshotComparer::Apps::Bootstrap.runner_list.map { |k, _| k }
          }
        rescue ArgumentError => e
          halt 404, 'invalid config file specified'
        end
      else
        halt 404, 'invalid sub app specified'
      end
    else
      halt 404, 'invalid application specified'
    end
  end

  post '/:application/applications/:name/remove_test_file' do |application, name|
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        begin
          test_file_list = params['remove_test_file']
          test_file_list.each do |test_file|
            Models::TestLocationFactory.new(new_app.db, new_app.fs_ip).remove_test_file(application, name, new_app.storage_info, test_file)
          end
          status 200
          erb :app_detail_update, :locals => {
            :application => app[:id],
            :sub_app_id => name.to_sym,
            :title => new_app.config['application']['name'],
            :request_response_list => Models::Test.new(new_app.db).get_setup_requests_by_name(app[:id], name),
            :config_list => Models::Configuration.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name),
            :test_location_list => Models::TestLocationFactory.new(new_app.db, new_app.fs_ip).get_by_name(app[:id], name),
            :test_type_list => SnapshotComparer::Apps::Bootstrap.test_list.map {|k, v| {:id => k, :name => v["name"] } },
            :runner_list => SnapshotComparer::Apps::Bootstrap.runner_list.map { |k, _| k }
          }
        rescue ArgumentError => e
          halt 404, 'invalid test file specified'
        end
      else
        halt 404, 'invalid sub app specified'
      end
    else
      halt 404, 'invalid application specified'
    end
  end

  get '/:application/applications/:name/test_download/:file_name' do |application, name, file_name|
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        begin
          downloaded_file =  Models::TestLocationFactory.new(new_app.db, new_app.fs_ip).get_by_id(application, name, file_name).download
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
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
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
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
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
          :load_test_list => SnapshotComparer::Apps::Bootstrap.test_list
        }
      else
        status 404
      end
    else
      status 404
    end
  end

  get '/:application/results/:name/:test' do |application, name, test|
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test)
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        results = SnapshotComparer::Models::PastSummaryResults.new(application, name,
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
          :result_set_list => results.past_summary_results.test_results(new_app.db, new_app.fs_ip, results.test_list).sort_by {|r| r.start.to_s},
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
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test)
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        metric_results = {} unless metric_results
        metric_results[metric.to_sym] = []
        results = SnapshotComparer::Models::PastSummaryResults.new(application, name,
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
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test)
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        results = SnapshotComparer::Models::PastSummaryResults.new(application, name,
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
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test)
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        app_type = new_app.config['application']['type'].to_sym
        results = SnapshotComparer::Models::PastSummaryResults.new(application, name,
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

  get '/:application/results/:name/:test/id/:id/plugin/:plugin/:option/find/:criteria' do |application, name, test, id, plugin, option, criteria|
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test)
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        plugin_instance = new_app.load_plugins.find {|p| p.to_s == plugin }
        halt 404, {'Content-Type' => 'application/json'},  {'fail' => "no plugin #{plugin} found"}.to_json  unless plugin_instance
        summary_plugin_data = plugin_instance.new(new_app.db, new_app.fs_ip).show_summary_data(
          application, name, test, option, id,
            {
              :application_type => new_app.config['application']['type'].to_sym,
              :find => criteria
            })
        summary_headers = nil
        summary_header_descriptions = nil

        #TODO: detailed data is not required for all plugin types.  have a condition to check if not available and then don't process it
        begin
          if summary_plugin_data && !summary_plugin_data.empty?
            plugin_type = new_app.config['application']['type'].to_sym == :comparison ? summary_plugin_data[:plugin_type] : summary_plugin_data.map{|k,v|
                v[:plugin_type]
              }.first

            content_type :json
            response = {
              :results => summary_plugin_data
            }
            body response.to_json
          else
            halt 404, {'Content-Type' => 'application/json'},  {'fail' => "no metric data found for #{application}/#{name}/#{test}/#{id}/#{plugin}/#{option}"}.to_json
          end
        rescue Exception => e
          p e
        end
      else
        halt 404, {'Content-Type' => 'application/json'},  {'fail' => "No sub application for #{name} found"}.to_json
      end
    else
      halt 404, {'Content-Type' => 'application/json'},  {'fail' => "No application by name of #{application}/#{test} found"}.to_json
    end
  end

  get '/:application/results/:name/:test/id/:id/plugin/:plugin/:option/:offset/:size' do |application, name, test, id, plugin, option, offset, size|
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test)
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        plugin_instance = new_app.load_plugins.find {|p| p.to_s == plugin }
        halt 404, {'Content-Type' => 'application/json'},  {'fail' => "no plugin #{plugin} found"}.to_json  unless plugin_instance
        summary_plugin_data = plugin_instance.new(new_app.db, new_app.fs_ip).show_summary_data(
          application, name, test, option, id,
            {
              :application_type => new_app.config['application']['type'].to_sym,
              :offset => offset,
              :size => size
            })
        summary_headers = nil
        summary_header_descriptions = nil

        #TODO: detailed data is not required for all plugin types.  have a condition to check if not available and then don't process it
        begin
          if summary_plugin_data && !summary_plugin_data.empty?
            plugin_type = new_app.config['application']['type'].to_sym == :comparison ? summary_plugin_data[:plugin_type] : summary_plugin_data.map{|k,v|
                v[:plugin_type]
              }.first

            content_type :json
            response = {
              :results => summary_plugin_data
            }
            body response.to_json
          else
            halt 404, {'Content-Type' => 'application/json'},  {'fail' => "no metric data found for #{application}/#{name}/#{test}/#{id}/#{plugin}/#{option}"}.to_json
          end
        rescue Exception => e
          p e
        end
      else
        halt 404, {'Content-Type' => 'application/json'},  {'fail' => "No sub application for #{name} found"}.to_json
      end
    else
      halt 404, {'Content-Type' => 'application/json'},  {'fail' => "No application by name of #{application}/#{test} found"}.to_json
    end
  end

  get '/:application/results/:name/:test/id/:id/plugin/:plugin/:option' do |application, name, test, id, plugin, option|
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test)
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        plugin_instance = new_app.load_plugins.find {|p| p.to_s == plugin }
        halt 404, "no plugin #{plugin} found" unless plugin_instance
        summary_plugin_data = plugin_instance.new(new_app.db, new_app.fs_ip).show_summary_data(
          application, name, test, option, id,
            {
              :application_type => new_app.config['application']['type'].to_sym
            })
        detailed_plugin_data = plugin_instance.new(new_app.db, new_app.fs_ip).show_detailed_data(
          application, name, test, option, id,
            {
              :application_type => new_app.config['application']['type'].to_sym
            })
        summary_headers = []
        summary_header_descriptions = []

        #TODO: detailed data is not required for all plugin types.  have a condition to check if not available and then don't process it
        begin
        if summary_plugin_data && !summary_plugin_data.empty?
          if new_app.config['application']['type'].to_sym == :comparison && [:time_series, :stacked_time_series].include?(summary_plugin_data[:plugin_type])
            summary_plugin_data[:id_results].each do |guid_results|
              guid_results[:results].each do |metric, metric_data|
                summary_headers = summary_headers ? (metric_data[:headers] | summary_headers) : metric_data[:headers]
                summary_header_descriptions = metric_data[:description]
                break
              end
            end
            if detailed_plugin_data
              detailed_plugin_result = []
              #TODO: this might be very time_series centric. Maybe should be moved out of here
              detailed_plugin_data[:id_results].each do |guid_results|
                detailed_guid_results = {}
                guid_results[:results].each do |key, value|
                  detailed_guid_results[key] = {}
                  detailed_guid_results[key][:headers] = value[:headers]
                  detailed_guid_results[key][:content] = {}
                  detailed_guid_results[key][:description] = value[:description]

                  value[:content].each do |instance, data|
                    detailed_guid_results[key][:content][instance] =
                      plugin_instance.new(new_app.db, new_app.fs_ip).order_by_date(data)
                  end
                end
                detailed_plugin_result << {:id => guid_results[:id], :results => detailed_guid_results}
              end
            end
          else
            if detailed_plugin_data
              detailed_plugin_result = {}
              detailed_plugin_data.each do |key, value|
                detailed_plugin_result[key] = {}
                detailed_plugin_result[key][:headers] = value[:headers]
                detailed_plugin_result[key][:content] = {}
                detailed_plugin_result[key][:description] = value[:description]

                value[:content].each do |instance, data|
                  detailed_plugin_result[key][:content][instance] =
                    plugin_instance.new(new_app.db, new_app.fs_ip).order_by_date(data)
                end
              end
            end
          end
          plugin_type = new_app.config['application']['type'].to_sym == :comparison ? summary_plugin_data[:plugin_type] : summary_plugin_data.map{|k,v|
              v[:plugin_type]
            }.first

          erb PluginModule::PluginView.retrieve_view(plugin_type,new_app.config['application']['type'].to_sym), :locals => {
            :application => app[:id],
            :sub_app_id => name.to_sym,
            :title => new_app.config['application']['name'],
            :summary_plugin_data => summary_plugin_data,
            :summary_headers => summary_headers,
            :summary_header_descriptions => summary_header_descriptions,
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
        rescue Exception => e
          p e.backtrace
          p e.message
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
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test)
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        results = SnapshotComparer::Models::PastSummaryResults.new(application, name,
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
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test)
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        begin
          downloaded_file =  SnapshotComparer::Models::TestLocationFactory.new(new_app.db, new_app.fs_ip).get_result_by_id(
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
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test)
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        results = SnapshotComparer::Models::PastSummaryResults.new(application, name,
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
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test)
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
          if detailed_plugin_data && !detailed_plugin_data.empty? && detailed_plugin_data[option.to_sym][:content].length > 0
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
    plugin_id = params[:plugin_id]

    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test)
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
        summary_headers = nil
        summary_header_descriptions = nil
        if new_app.config['application']['type'].to_sym == :comparison
          summary_plugin_data = plugin_instance.new(new_app.db, new_app.fs_ip).show_summary_data(application, name, test, option, params[:compare], {:application_type => new_app.config['application']['type'].to_sym})
          if summary_plugin_data && !summary_plugin_data.empty?
            summary_plugin_data[:id_results].each do |guid_results|
              guid_results[:results].each do |metric, metric_data|
                summary_headers = summary_headers ? (metric_data[:headers] | summary_headers) : metric_data[:headers]
                summary_header_descriptions = metric_data[:description]
                break
              end if guid_results[:results]
              valid_comparison_id_list << guid_results[:id]
            end
            summary_plugin_data_list = summary_plugin_data[:id_results]
            plugin_type = summary_plugin_data[:plugin_type]
            params[:compare].split('+').each {|id| valid_comparison_id_list << id }
          else
            halt 404, "No data for #{plugin_id} found"
          end
        else
          params[:compare].split('+').each do |id|
            summary_plugin_data = plugin_instance.new(new_app.db, new_app.fs_ip).show_summary_data(application, name, test, option, id)
            if summary_plugin_data && !summary_plugin_data.empty? && summary_plugin_data[option.to_sym][:content].length > 0
              summary_plugin_data_list << {
                :id => id,
                :results => summary_plugin_data
              }
              valid_comparison_id_list << id
              plugin_type = summary_plugin_data.map{|k,v|
                            v[:plugin_type]
                          }.first
              summary_plugin_data.each do |key, content|
                summary_headers = summary_headers ? (content[:headers] | summary_headers) : content[:headers]
                summary_header_descriptions = content[:description]
                break
              end
            end
          end
        end

        #detailed_plugin_data = plugin_instance.new(new_app.db, new_app.fs_ip).show_detailed_data(application, name, test, option, id)
        if valid_comparison_id_list.length > 0 && !summary_plugin_data_list.empty?
          erb PluginModule::PluginView.retrieve_compare_view(
            plugin_type,
            new_app.config['application']['type'].to_sym
            ), :locals => {
              :application => app[:id],
              :sub_app_id => name.to_sym,
              :title => new_app.config['application']['name'],
              :summary_plugin_data_list => summary_plugin_data_list,
              :test_type => test,
              :summary_headers => summary_headers,
              :summary_header_descriptions => summary_header_descriptions,
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
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      erb :tests, :locals => {
        :application_list => new_app.retrieve_sub_apps_for_running_tests,
        :title => new_app.config['application']['name'],
        :application => app[:id]
      }
    else
      status 404
    end
  end

  get '/:application/tests/:name' do |application, name|
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new
      sub_app = new_app.retrieve_sub_apps_for_running_tests.find do |sa|
        sa['id'] == name
      end
      if sub_app
        erb :tests_list, :locals => {
          :application => app[:id],
          :sub_app_id => name.to_sym,
          :title => new_app.config['application']['name'],
          :load_test_list => new_app.highlight_currently_running_tests(application, sub_app)
        }
      else
        status 404
      end
    else
      status 404
    end
  end

=begin
  only allow adhoc to start tests (this logic should be loaded from repose app)
  if test is running, show when done (this logic should be loaded from repose app) - DONE
  adhoc needs to be done first...can look at rest later
    - get /:application/tests/:name/adhoc >> show start time and possible end time for the current test (explain that this is a origin test and it might be 1st of 2)
    - dropdown to select test type (load, duration, stress, custom)
      - if custom, select time length, rampup, and target throughput
    - dropdown to select config type (show all sub apps and custom)
      - if custom, allow to upload zip of configs
    - dropdown to select source code (all versions and custom)
      - if custom, enter git repository and git branch (placeholder for master)
    - button to schedule test
      - POST /:application/tests/:name/adhoc/start
        - sets everything up and starts the test
=end
  get '/:application/tests/:name/:test' do |application, name, test|
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test)
      new_app = app[:klass].new
      sub_app = new_app.retrieve_sub_apps_for_running_tests.find do |sa|
        sa['id'] == name
      end
      if sub_app
        if test == 'adhoc_test'
          erb new_app.retrieve_adhoc_view(name), :locals => new_app.retrieve_adhoc_view_locals(application, name, test)
        else
          erb :tests_app_test_detail, :locals => {
            :application => app[:id],
            :test_type => test,
            :sub_app_id => name.to_sym,
            :title => new_app.config['application']['name'],
            :results => SnapshotComparer::Models::LiveSummaryResults.start_running_results(name, test.chomp('_test')),
            :result_set_list => SnapshotComparer::Models::LiveSummaryResults.start_running_results(name, test.chomp('_test')).summary_results
          }
        end
      else
        status 404
      end
    else
      status 404
    end
  end

=begin
  1. execute start test here
  2. for now, just add to execution point
=end
  post '/:application/tests/:name/:test' do |application, name, test|
    test_list = {
     'load_test' => {
        'length' => 60,
        'throughput' => 500
      },
     'duration_test' => {
        'length' => 480,
        'throughput' => 400
      },
     'stress_test' => {
        'length' => 120,
        'throughput' => 10000
      }
    }

    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and (SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test) or SnapshotComparer::Apps::Bootstrap.test_list.keys.include?("#{test}_test"))
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        if params
          json_data ={
            'name' => params['test_name'],
            'description' => params['description'],
            'flavor_type' => params['flavor_type'],
            'runner' => 'jmeter'
          }
          if !params['git_repo'].empty?
            json_data['version'] = 'build'
            json_data['git_repo'] = params['git_repo']
            json_data['branch'] ||= 'master'
          else
            json_data['version'] = params['versions']
          end

          if params['test_type'] == 'custom'
            json_data['length'] = params['length']
            json_data['throughput'] = params['throughput']
          else
            json_data['test_type'] = params['test_type']
            json_data['length'] = test_list[params['test_type']]['length']
            json_data['throughput'] = test_list[params['test_type']]['throughput']
          end
        end

        halt 400, { "fail" => "required keys are missing"}.to_json unless json_data.has_key?("name") and json_data.has_key?("length") and json_data.has_key?("runner")
        guid_response = new_app.start_test_recording(application, name, test.chomp('_test'), json_data, Time.now)
        halt 400, {'Content-Type' => 'application/json'}, {'fail' => "test for #{application}/#{name}/#{test} already started"}.to_json if guid_response.length == 0
        halt 400, {'Content-Type' => 'application/json'}, guid_response if JSON.parse(guid_response).has_key?("fail")
        if test == 'adhoc_test'
          erb new_app.retrieve_adhoc_view(name), :locals => new_app.retrieve_adhoc_view_locals(application, name, test)
        else
          erb :tests_app_test_detail, :locals => {
            :application => app[:id],
            :test_type => test,
            :sub_app_id => name.to_sym,
            :title => new_app.config['application']['name'],
            :results => Results::LiveSummaryResults.start_running_results(name, test.chomp('_test')),
            :result_set_list => Results::LiveSummaryResults.start_running_results(name, test.chomp('_test')).summary_results
          }
        end
      end
    end
  end

=begin
  use this to monitor logs for the test setup and execution
=end
  get '/:application/tests/:name/:test/monitor' do |application, name, test|

  end

  post '/:application/applications/:name/:test/start' do |application, name, test|
=begin
  POST /atom_hopper/applications/main/load/start -d '{"length":60, "description": "this is a description of the test", "flavor_type": "performance", "release": 1.6}'
=end
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and (SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test) or SnapshotComparer::Apps::Bootstrap.test_list.keys.include?("#{test}_test"))
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
        halt 400, {'Content-Type' => 'application/json'}, {'fail' => "test for #{application}/#{name}/#{test} already started"}.to_json if guid_response.length == 0
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
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and (SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test) or SnapshotComparer::Apps::Bootstrap.test_list.keys.include?("#{test}_test"))
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        request.body.rewind
        json_data = JSON.parse(request.body.read)
        content_type :json
        halt 400, { "fail" => "required keys are missing"}.to_json unless json_data.has_key?("guid") and json_data.has_key?("servers") and json_data["servers"].has_key?("results")
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
end
