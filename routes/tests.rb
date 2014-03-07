  puts 'tests'
  get '/:application/tests' do |application|
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
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
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
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
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    puts app
    if app and Apps::Bootstrap.test_list.keys.include?(test)
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
            :results => Results::LiveSummaryResults.start_running_results(name, test.chomp('_test')),
            :result_set_list => Results::LiveSummaryResults.start_running_results(name, test.chomp('_test')).summary_results
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

    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and (Apps::Bootstrap.test_list.keys.include?(test) or Apps::Bootstrap.test_list.keys.include?("#{test}_test"))
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
        guid_response = new_app.start_test_recording(application, name, test.chomp('_test'), json_data)
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
