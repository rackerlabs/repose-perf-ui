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
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
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
          :test_type_list => Apps::Bootstrap.test_list.map {|k, v| {:id => k, :name => v["name"] } },
          :runner_list => Apps::Bootstrap.runner_list.map { |k, _| k }
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
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
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
            :test_type_list => Apps::Bootstrap.test_list.map {|k, v| {:id => k, :name => v["name"] } },
            :runner_list => Apps::Bootstrap.runner_list.map { |k, _| k }
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
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
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
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
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
            :test_type_list => Apps::Bootstrap.test_list.map {|k, v| {:id => k, :name => v["name"] } },
            :runner_list => Apps::Bootstrap.runner_list.map { |k, _| k }
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
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
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
            :test_type_list => Apps::Bootstrap.test_list.map {|k, v| {:id => k, :name => v["name"] } },
            :runner_list => Apps::Bootstrap.runner_list.map { |k, _| k }
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
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
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
            :test_type_list => Apps::Bootstrap.test_list.map {|k, v| {:id => k, :name => v["name"] } },
            :runner_list => Apps::Bootstrap.runner_list.map { |k, _| k }
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
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
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
            :test_type_list => Apps::Bootstrap.test_list.map {|k, v| {:id => k, :name => v["name"] } },
            :runner_list => Apps::Bootstrap.runner_list.map { |k, _| k }
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
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
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
            :test_type_list => Apps::Bootstrap.test_list.map {|k, v| {:id => k, :name => v["name"] } },
            :runner_list => Apps::Bootstrap.runner_list.map { |k, _| k }
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
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
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

  post '/:application/applications/:name/:test/start' do |application, name, test|
=begin
  POST /atom_hopper/applications/main/load/start -d '{"length":60, "description": "this is a description of the test", "flavor_type": "performance", "release": 1.6}'
=end
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and (Apps::Bootstrap.test_list.keys.include?(test) or Apps::Bootstrap.test_list.keys.include?("#{test}_test"))
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
    app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and (Apps::Bootstrap.test_list.keys.include?(test) or Apps::Bootstrap.test_list.keys.include?("#{test}_test"))
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
