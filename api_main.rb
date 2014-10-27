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
    content_type :json
    body SnapshotComparer::Apps::Bootstrap.application_list.to_json
  end

  get '/:application/applications' do |application|
    content_type :json
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      body new_app.config['application']['sub_apps'].to_json
    else
      status 404
    end
  end

  get '/:application/applications/:name/types' do |application, name|
    content_type :json
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        body SnapshotComparer::Apps::Bootstrap.test_list.map {|k, v| {:id => k, :name => v["name"] } }.to_json
      else
        status 404
      end
    else
      status 404
    end
  end

  get '/:application/running_tests' do |application|
    content_type :json
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      sub_apps = []
      new_app.config['application']['sub_apps'].each do |sa|
        sa['status'] = SnapshotComparer::Models::ApplicationTestType.new(nil, new_app.db).get_overall_status(application, sa['id'])
        sa['status'] ||= SnapshotComparer::Models::ApplicationTestType.PASSED
        sub_apps << sa
      end

      body sub_apps.to_json 
    else
      status 404
    end
  end

  get '/:application/stats/:name' do |application, name|
    content_type :json
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      test_list = {}
      SnapshotComparer::Apps::Bootstrap.test_list.each do |id, t|
        t['status'] = SnapshotComparer::Models::ApplicationTestType.new(nil, new_app.db).get_status_for_type(app[:id], name.to_sym, id)
        t['status'] ||= SnapshotComparer::Models::ApplicationTestType.PASSED
        t['test_count'] = SnapshotComparer::Models::PastSummaryResults.new(application, name,
            new_app.config['application']['type'].to_sym, id.chomp('_test'),
            new_app.db, new_app.fs_ip, nil, logger).test_list.count
        t['test_count'] ||= 0
        test_list.merge!({id => t})
      end
      if sub_app
        body test_list.to_json
      else
        status 404
      end
    else
      status 404
    end
  end

  get '/:application/running_tests/:name/:test_type' do |application, name, test_type|
    content_type :json
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      running_test = SnapshotComparer::Models::Results.new.get_running_test(new_app.db, application, name, test_type) 
      if running_test
        body running_test
      else
        status 404
      end
    else
      status 404
    end
  end

  get '/:application/running_tests/:name' do |application, name|
    content_type :json
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      running_tests = []
      SnapshotComparer::Apps::Bootstrap.test_list.each do |test_type, _ |
        running_test = SnapshotComparer::Models::Results.new.get_running_test(new_app.db, application, name, test_type.chomp('_test')) 
        running_tests << JSON.parse(running_test) if running_test
      end
      body running_tests.to_json
    else
      status 404
    end
  end

  get '/:application/running_tests/:name/:test_type/state' do |application, name, test_type|
    content_type :json
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if SnapshotComparer::Models::Results.new.get_state(new_app.db, application, name, test_type.chomp('_test')) 
        body 'SPINNING-UP'
      elsif SnapshotComparer::Models::Results.new.get_running_test(new_app.db, application, name, test_type.chomp('_test'))
        body 'RUNNING'
      else
        body 'NONE'
      end
    else
      status 404
    end
  end

  post '/:application/tests/:name/:test' do |application, name, test|
    content_type :json
    app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
    if app and (SnapshotComparer::Apps::Bootstrap.test_list.keys.include?(test) or SnapshotComparer::Apps::Bootstrap.test_list.keys.include?("#{test}_test"))
      new_app = app[:klass].new(settings.deployment)
      sub_app = new_app.config['application']['sub_apps'].find do |sa|
        sa['id'] == name
      end
      if sub_app
        request.body.rewind  # in case someone already read it
        data = JSON.parse request.body.read
        # check all required data
        halt 400, {'fail' => 'not all required data is there'}.to_json unless data['length'] && data['name']
        # add data to redis
        # for the application, run the .sh file
        pid = SnapshotComparer::Models::Test.new(new_app.db).start_test(application, name, test, data)
        if pid > 0
          status 200
        else
          status 500
        end
      end
    end
  end

end
end
