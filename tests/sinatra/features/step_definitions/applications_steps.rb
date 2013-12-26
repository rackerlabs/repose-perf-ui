require 'json'
require 'redis'

set_name = nil
set_app = nil

Transform /^(-?\d+)$/ do |number|
  number.to_i
end

Given(/^"(.*?)" request exists in "(.*?)" "(.*?)" application$/) do |count, application, name|
  Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = Apps::Bootstrap.storage_info
  app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app 
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    current_request_count = JSON.parse(Redis.new(new_app.db).get("#{application}:#{name}:tests:setup:request_response:request")).length
    if new_app
      if current_request_count > count
        request_list = JSON.parse(Redis.new(new_app.db).get("#{application}:#{name}:tests:setup:request_response:request"))
        request_list.pop(current_request_count - count)
        Redis.new(new_app.db).set("#{application}:#{name}:tests:setup:request_response:request", request_list.to_json)
      end
      set_name = name
      set_app = application
    end
  end
end

Given(/^"(.*?)" response exists in "(.*?)" "(.*?)" application$/) do |count, application, name|
  Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = Apps::Bootstrap.storage_info
  app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app 
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    current_response_count = JSON.parse(Redis.new(new_app.db).get("#{application}:#{name}:tests:setup:request_response:response")).length
    if new_app
      if current_response_count > count
        response_list = JSON.parse(Redis.new(new_app.db).get("#{application}:#{name}:tests:setup:request_response:response"))
        response_list.pop(current_response_count - count)
        Redis.new(new_app.db).set("#{application}:#{name}:tests:setup:request_response:response", response_list.to_json)
      end
      set_name = name
      set_app = application
    end
  end
end

Given(/^"(\d+)" config files exist in "(.*?)" "(.*?)" application$/) do |count, application, name|
  Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = Apps::Bootstrap.storage_info
  app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app 
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    current_config_count = Redis.new(new_app.db).lrange("#{application}:#{name}:setup:configs", 0, -1).length
    if new_app
      if current_config_count > count
        config = Redis.new(new_app.db).rpop("#{application}:#{name}:setup:configs")
        config_location = JSON.parse(config)['location']
        FileUtils.rm_rf("#{storage_info['path']}/#{config_location}")
      end
      set_name = name
      set_app = application
    end
  end
end

Given(/^"(.*?)" config file exists in "(.*?)" "(.*?)" application$/) do |config_name, application, name|
  Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = Apps::Bootstrap.storage_info
  app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app 
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    if new_app
      config_json = {
        "name" => config_name,
        "location" => "/#{storage_info['prefix']}/#{application}/#{name}/setup/configs/#{config_name}"
      }
      File.open("#{storage_info['path']}/#{storage_info['prefix']}/#{application}/#{name}/setup/configs/#{config_name}", "w") do |f|
        f.write "test"
      end
      Redis.new(new_app.db).rpush("#{application}:#{name}:setup:configs", config_json.to_json)
      set_name = name
      set_app = application
    end
  end
end

Given(/^"(.*?)" "(.*?)" "(.*?)" test files exist in "(.*?)" "(.*?)" application$/) do |count, runner, test_type, application, name|
  Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = Apps::Bootstrap.storage_info
  app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app 
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    test_file_json = {
      "type" => runner,
      "test" => test_type,
      "location" => "/#{storage_info['prefix']}/#{application}/#{name}/setup/meta/#{runner}_#{test_type}"
    }

    if new_app
      while Redis.new(new_app.db).lrange("#{application}:#{name}:tests:setup:script", 0, -1).find_all { |t|
          t == test_file_json.to_json
      }.length > count
        test_file = Redis.new(new_app.db).rpop("#{application}:#{name}:tests:setup:script")
        test_file_location = JSON.parse(test_file)['location']
        FileUtils.rm_rf("#{storage_info['path']}/#{test_file_location}")
      end
      set_name = name
      set_app = application
    end
  end
end

Given(/^"(.*?)" "(.*?)" test file exists in "(.*?)" "(.*?)" application$/) do |runner, test_type, application, name|
  Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = Apps::Bootstrap.storage_info
  app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app 
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    if new_app
      test_file_json = {
        "type" => runner,
        "test" => test_type,
        "location" => "/#{storage_info['prefix']}/#{application}/#{name}/setup/meta/#{runner}_#{test_type}"
      }
      File.open("#{storage_info['path']}/#{storage_info['prefix']}/#{application}/#{name}/setup/meta/#{runner}_#{test_type}", "w") do |f|
        f.write "test"
      end
      Redis.new(new_app.db).rpush("#{application}:#{name}:tests:setup:script", test_file_json.to_json)
      set_name = name
      set_app = application
    end
  end
end

Then(/^the "(.*?)" directory should contain "(.*?)" file$/) do |directory, name|
  Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = Apps::Bootstrap.storage_info
  puts `ls "#{storage_info['path']}/#{storage_info['prefix']}/#{directory}/"`
  File.exists?("#{storage_info['path']}/#{storage_info['prefix']}/#{directory}/#{name}").should be(true)
end

Then(/^remove "(.*?)" config from "(.*?)" "(.*?)"$/) do |config_name, application, name|
  Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = Apps::Bootstrap.storage_info
  app = Apps::Bootstrap.application_list.find {|a| a[:id] == set_app}
  if app 
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    if new_app 
      config_json = JSON.parse(Redis.new(new_app.db).lrange("#{application}:#{name}:setup:configs", 0, -1).find do |c|
        temp = JSON.parse(c)
        temp['name'] == config_name
      end)
      config = Redis.new(new_app.db).lrem("#{application}:#{name}:setup:configs", 100, config_json.to_json)
      config_location = config_json['location']
      FileUtils.rm_rf("#{storage_info['path']}/#{config_location}")
    end
  end   
end

Then(/^remove "(.*?)" "(.*?)" "(.*?)" test file for "(.*?)" "(.*?)"$/) do |file_name, runner, test_type, application, name|
  Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = Apps::Bootstrap.storage_info
  app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app 
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    if new_app 
      test_file_json = {
        "type" => runner,
        "test" => test_type,
        "name" => file_name,
        "location" => "/#{storage_info['prefix']}/#{application}/#{name}/setup/meta/#{file_name}"
      }
      test_file = Redis.new(new_app.db).lrem("#{application}:#{name}:tests:setup:script", 100, test_file_json.to_json)
      test_file_location = test_file_json['location']
      FileUtils.rm_rf("#{storage_info['path']}/#{test_file_location}")
    end
  end   
end

Then(/^remove "(.*?)" "(.*?)" from redis "(.*?)" key for "(.*?)"$/) do |key, id, redis_key, application|
  Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = Apps::Bootstrap.storage_info
  app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app 
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    if new_app 
      list = Redis.new(new_app.db).get(redis_key)
      tmp = JSON.parse(list)
      list_json = tmp.delete_if {|k| k[key] == id}
      Redis.new(new_app.db).set(redis_key, list_json.to_json)
    end
  end   
end

Then(/^the "(.*?)" json list should have "(.*?)" entries in redis for "(.*?)"$/) do |redis_key, count, application|
  Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = Apps::Bootstrap.storage_info
  app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app 
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    if new_app 
      list = Redis.new(new_app.db).get(redis_key)
      JSON.parse(list).length.should == count.to_i
    end
  end   
end

Then(/^the "(.*?)" json list should contain "(.*?)" key with "(.*?)" value in redis for "(.*?)"$/) do |redis_key, key, value, application|
  Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = Apps::Bootstrap.storage_info
  app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app 
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    if new_app 
      list = JSON.parse(Redis.new(new_app.db).get(redis_key))
      list.find {|e| e[key] == value}.should_not be_nil
    end
  end   
end

Then(/^update "(.*?)" "(.*?)" from redis "(.*?)" key for "(.*?)":$/) do |key, value, redis_key, application, updated_data|
  Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = Apps::Bootstrap.storage_info
  app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app 
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    if new_app 
      list = JSON.parse(Redis.new(new_app.db).get(redis_key))
      element = list.find {|e| e[key].to_i == value.to_i }
      element = JSON.parse(updated_data)
      list.delete_if {|k| k[key].to_i == value.to_i}
      list << element
      Redis.new(new_app.db).set(redis_key, list.to_json)
    end
  end   
end

Then(/^add "(.*?)" "(.*?)" from redis "(.*?)" key for "(.*?)":$/) do |key, value, redis_key, application, updated_data|
  Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = Apps::Bootstrap.storage_info
  app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app 
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    if new_app 
      list = JSON.parse(Redis.new(new_app.db).get(redis_key))
      list << JSON.parse(updated_data)
      Redis.new(new_app.db).set(redis_key, list.to_json)
    end
  end   
end
