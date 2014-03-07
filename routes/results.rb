puts 'results'

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

  get '/:application/results/:name/:test/id/:id/plugin/:plugin/:option/find/:criteria' do |application, name, test, id, plugin, option, criteria|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and Apps::Bootstrap.test_list.keys.include?(test)
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
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and Apps::Bootstrap.test_list.keys.include?(test)
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
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and Apps::Bootstrap.test_list.keys.include?(test)
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
          if new_app.config['application']['type'].to_sym == :comparison && summary_plugin_data[:plugin_type] == :time_series
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
          p e
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
