require 'json'
require 'redis'

temp_results = ''
results = ''
guid = nil
fs_ip = nil
set_app = nil
set_name = nil
set_test = nil
config_count = 0
current_config_count = 0


Given(/^Test for "(.*?)" "(.*?)" "(.*?)"$/) do |application, name, test|
  set_app = application
  set_name = name
  set_test = test
end

Given(/^No tests are started for "(.*?)" "(.*?)" "(.*?)"$/) do |application, name, test|
  #here, check that no ids are in "application:test:main:load_test:start"
  SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    Redis.new(new_app.db).del("#{application}:test:#{name}:#{test}:start")
  end
end

Given(/^Test is started for "(.*?)" "(.*?)" "(.*?)"$/) do |application, name, test|
  SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    fs_ip = new_app.fs_ip
    time = Time.now
    time = time - 3600
    guid = SecureRandom.uuid
    data =  {
      "length" => 60,
      "description" => "this is a description of the test",
      "flavor_type" => "performance",
      "release" => "1.6",
      "name" => "this is my name",
      "runner" => "jmeter"
    }
    start_test = {:guid => guid, :time => time }.merge(data).to_json
    Redis.new(new_app.db).set("#{application}:test:#{name}:#{test}:start", start_test)
    set_app = application
    set_name = name
    set_test = test
  end
end

Given(/^Test is started for "(.*?)" "(.*?)" "(.*?)" initial test$/) do |application, name, test|
  SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    fs_ip = new_app.fs_ip
    time = Time.now
    guid = SecureRandom.uuid
    data =  {
      "length" => 60,
      "description" => "this is a description of the test",
      "flavor_type" => "performance",
      "release" => "1.6",
      "name" => "this is my name",
      "runner" => "jmeter"
    }
    start_test = {:guid => guid, :time => time }.merge(data).to_json
    Redis.new(new_app.db).set("#{application}:test:#{name}:#{test}:start", start_test)
    set_app = application
    set_name = name
    set_test = test
  end
end

Given(/^Test is started for "(.*?)" "(.*?)" "(.*?)" secondary test$/) do |application, name, test|
  SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    started_test = JSON.parse(Redis.new(new_app.db).get("#{application}:test:#{name}:#{test}:start"))
    set_app = application
    set_name = name
    set_test = test
    guid = started_test['guid']
  end
end

Given(/^Running for "(.*?)" "(.*?)" "(.*?)"$/) do |application, name, test|
  SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    fs_ip = new_app.fs_ip
    time = Time.now
    guid = SecureRandom.uuid
    data =  {
      "length" => 60,
      "description" => "this is a description of the test",
      "flavor_type" => "performance",
      "release" => "1.6",
      "name" => "this is my name",
      "runner" => "jmeter",
      "comparison_guid" => "some-other-string"
    }
    start_test = {:guid => guid, :time => time }.merge(data).to_json
    Redis.new(new_app.db).set("#{application}:test:#{name}:#{test}:start", start_test)
    set_app = application
    set_name = name
    set_test = test
  end
end

When(/^I post to "([^\"]*)" with '(.*?)'$/) do |path, post_data|
  	post(path, JSON.parse(post_data))
end

When(/^I post to "([^\"]*)" with checkbox name "(.*?)" and values "(.*?)"$/) do |path, name, list|
    post(path, {name => list.split(',')})
end

When(/^I post to '([^\"]*)' with existing guid:$/) do |path, post_data|
    test = JSON.parse(post_data)
    test['guid'] = guid
    data = test.to_json
    post(path, data)
end

When(/^I post to '([^\"]*)' with:$/) do |path, post_data|
    post(path, post_data)
end

When(/^I post to "([^\"]*)" with:$/) do |path, post_data|
    post(path, JSON.parse(post_data))
end

When(/^I delete from "([^\"]*)"$/) do |path|
    delete path
end

#When /^I navigate to '([^\"]*)'$/ do |path|
#  	get path
#end

When /^I click on '([^\"]*)'$/ do |path|
  	get path
end

When(/^I load 1 more record in "(.*?)" app and "(.*?)" test type$/) do |app, test_type|
	live_summary_results = Results::LiveSummaryResults.new(app,test_type)
	results = File.read(live_summary_results.summary_location)
	temp_results = results + "\nsummary +   6257 in     6s = 1037.1/s Avg:    38 Min:    33 Max:   267 Err:     0 (0.00%) Active: 40 Started: 40 Finished: 0\n"
	temp_results += "summary = 3066619 in  3000s = 1022.3/s Avg:    38 Min:    32 Max:  3058 Err:     0 (0.00%)"
	File.open(live_summary_results.summary_location, 'w') {|f| f.write(temp_results)}
end

When(/^I wait "(.*?)" seconds$/) do |seconds|
  	sleep seconds.to_i
end

When(/^I post to '([^\"]*)' with non\-existing guid$/) do |path, post_data|
    test = JSON.parse(post_data)
    test['guid'] = '000-000-000'
    data = test.to_json
    post(path, data)
end

Then /^the error should match the "([^\"]*)"$/ do |error|
  last_response.body.include?(error).should be(true)
end

Then /^the message should contain "([^\"]*)"$/ do |msg|
  last_response.body.include?(msg.to_s).should be(true)
end

Then /^the message should not contain "([^\"]*)"$/ do |msg|
  last_response.body.include?(msg.to_s).should be(false)
end

Then /^the file upload response should be ([^\"]*)$/ do |status|
  page.status_code.should == status.to_i
end

Then /^the file upload response should be json$/ do
    is_json = begin
      !!JSON.parse(page.body)
    rescue
      false
    end
  is_json == true
end

Then(/^the "(.*?)" list should contain "(.*?)" json entries in redis for "(.*?)" "(.*?)"$/) do |redis_key, count, application, name|
  result = nil
  main_config = SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    result = Redis.new(new_app.db).lrange("#{application}:#{name}:setup:configs", 0, -1)
    result.length.should == count.to_i
  end
  result.should_not be_nil

end

Then(/^the "(.*?)" list should contain "(.*?)" entries in redis for "(.*?)" application$/) do |list, count, application|
  result = nil
  main_config = SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    result = Redis.new(new_app.db).lrange(list, 0, -1)
    result.length.should == count.to_i
  end
  result.should_not be_nil
end

Then(/^the "(.*?)" directory should contain "(.*?)" entries for "(.*?)" application$/) do |directory, count, application|
  SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = SnapshotComparer::Apps::Bootstrap.storage_info
  Dir.entries("#{storage_info['path']}/#{storage_info['prefix']}/#{directory}").size.should be(count + 2)
end

Then /^the response should be "([^\"]*)"$/ do |status|
	last_response.status.should == status.to_i
end

Then /^response should be a json$/ do
    is_json = begin
      !!JSON.parse(last_response.body)
    rescue
      false
    end
	is_json == true
end

Then(/^there should be "(\d+)" records in response$/) do |count|
  results = JSON.parse(last_response.body)
  results.length.should == count.to_i
end

Then(/^there should be "(\d+)" "(\w+)" records in response$/) do |count, type|
  results = JSON.parse(last_response.body)
  if count.to_i == 0
    results[type].should be_nil
  else
    results[type].length.should == count.to_i
  end
end

Then(/^there should be "(\d+)" "(\w+)" "(.*?)" records in response$/) do |count, type, test_id|
  results = JSON.parse(last_response.body)
  if count.to_i == 0
    results[type].should == nil
  else
    results[type][test_id].length.should == count.to_i
  end
end

Then(/^"(.*?)" json record should equal to "(.*?)"$/) do |key, value|
  results = JSON.parse(last_response.body)
  results[key].should == value
end

Then(/^"(.*?)" list has "(.*?)" record, which should equal to "(.*?)"$/) do |list, key, value|
  result = nil
  results = JSON.parse(last_response.body)
  result = results[list].find{|l| l.has_key?(key)}
  result[key].should == value
  result.should_not be_nil
end

Then(/^"(.*?)" list has "(.*?)" record, which should contain "(.*?)"$/) do |list, key, value|
  result = nil
  results = JSON.parse(last_response.body)
  result = results[list].find{|l| l.has_key?(key)}
  result[key].should include(value)
  result.should_not be_nil
end

Then(/^"([\w_]+)" "([\w_]+)" json should equal to "(.*?)"$/) do |key_one, key_two, value|
  results = JSON.parse(last_response.body)
  results[key_one][key_two].should == value
end

Then(/^"(.*?)" json record should exist$/) do |key|
  results = JSON.parse(last_response.body)
  results[key].should_not be_nil
end

Then(/^there should be "(\d+)" tests in response$/) do |count|
  results = JSON.parse(last_response.body)
  results.length.should == count.to_i
end

Then(/^the test should have ended$/) do
  results = JSON.parse(last_response.body)
  results['ended'].should == true
end

Then(/^the test should not have ended$/) do
  results = JSON.parse(last_response.body)
  results['ended'].should == false
end

Then(/^the record in "(.*?)" app and "(.*?)" test type should be cleaned up$/) do |app, test_type|
	live_summary_results = Results::LiveSummaryResults.new(app,test_type)
	File.open(live_summary_results.summary_location, 'w') {|f| f.write(results)}
end

Then /^the page should match the "([^\"]*)" version$/ do |template|
	result = File.read(File.join(File.dirname(__FILE__), '..', "views/#{template}.html"))
	last_response.body.should == result
end

Then /^the page should contain the "([^\"]*)" version$/ do |template|
	result = File.read(File.join(File.dirname(__FILE__), '..', "views/#{template}.html"))
	last_response.body.should match /#{Regexp.escape(result)}/
end

Then /^the download page should match the "([^\"]*)" version$/ do |runner|
	result = File.read(File.join(File.dirname(__FILE__), '..', "views/#{runner}.runner"))
	last_response.body.should == result
end

Then(/^the "(.*?)" json entry for "(.*?)" hash key in redis should exist$/) do |entry, key|
  result = nil
  main_config = SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == set_app}
  if app
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    result = Redis.new(new_app.db).hget("#{set_app}:#{set_name}:results:#{set_test}:#{guid}:#{key}", entry)
  end
  result.should_not be_nil
end

Then(/^the "(.*?)" json entry for "(.*?)" hash key in redis should not exist$/) do |entry, key|
  result = nil
  main_config = SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == set_app}
  if app
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    result = Redis.new(new_app.db).hget("#{set_app}:#{set_name}:results:#{set_test}:#{guid}:#{key}", entry)
  end
  result.should be_nil
end

Then(/^the "(.*?)" list key in redis should exist and contain "(\d+)" entries$/) do |key, entry_count|
  result = false
  main_config = SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == set_app}
  if app
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    result_list = Redis.new(new_app.db).lrange("#{set_app}:#{set_name}:results:#{set_test}:#{guid}:#{key}", 0, -1)
    result = (result_list.length == entry_count.to_i)
  end
  result.should be(true)
end

Then(/^the "(.*?)" key in redis should not exist$/) do |key|
  result = true
  main_config = SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == set_app}
  if app
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    result = Redis.new(new_app.db).exists("#{set_app}:#{set_name}:results:#{set_test}:#{guid}:#{key}")
  end
  result.should be(false)
end

Then(/^the "(.*?)" directory should not contain "(.*?)" file$/) do |directory, name|
  SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = SnapshotComparer::Apps::Bootstrap.storage_info
  File.exists?("#{storage_info['path']}/#{storage_info['prefix']}/#{set_app}/#{set_name}/results/#{set_test}/#{guid}/#{directory}/#{name}").should be(false)
end

Then(/^the "(.*?)" directory should contain "(.*?)" result file$/) do |directory, name|
  SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = SnapshotComparer::Apps::Bootstrap.storage_info
  File.exists?("#{storage_info['path']}/#{storage_info['prefix']}/#{set_app}/#{set_name}/results/#{set_test}/#{guid}/#{directory}/#{name}").should be(true)
end

Then(/^the "(.*?)" directory should not contain "(.*?)" result file$/) do |directory, name|
  SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = SnapshotComparer::Apps::Bootstrap.storage_info
  File.exists?("#{storage_info['path']}/#{storage_info['prefix']}/#{set_app}/#{set_name}/results/#{set_test}/#{guid}/#{directory}/#{name}").should be(false)
end

Then(/^the "(.*?)" json entry for "(.*?)" hash key in redis does not contain "(.*?)" key and "(.*?)" value$/) do |entry, key, json_key, json_value|
  result = nil
  main_config = SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == set_app}
  if app
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    result = JSON.parse(Redis.new(new_app.db).hget("#{set_app}:#{set_name}:results:#{set_test}:#{guid}:#{key}", entry))
    result.has_key?(json_key).should be(false)
  end
  result.should_not be_nil
end

Then(/^the "(.*?)" json entry for "(.*?)" hash key in redis contains "(.*?)" key and "(.*?)" value$/) do |entry, key, json_key, json_value|
  result = nil
  main_config = SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == set_app}
  if app
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    result = JSON.parse(Redis.new(new_app.db).hget("#{set_app}:#{set_name}:results:#{set_test}:#{guid}:#{key}", entry))
    result[json_key].should == json_value
  end
  result.should_not be_nil
end

After('~@index,~@application') do |scenario|
puts 'After index'
  SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = SnapshotComparer::Apps::Bootstrap.storage_info
  FileUtils.rm_rf("#{storage_info['path']}/#{storage_info['prefix']}/#{set_app}/#{set_name}/results/#{set_test}/#{guid}")
  app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == set_app}
  if app
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    if new_app
      Redis.new(new_app.db).del("#{set_app}:#{set_name}:results:#{set_test}:#{guid}:data")
      Redis.new(new_app.db).del("#{set_app}:#{set_name}:results:#{set_test}:#{guid}:meta")
      Redis.new(new_app.db).del("#{set_app}:#{set_name}:results:#{set_test}:#{guid}:configs")
      Redis.new(new_app.db).lrem("#{set_app}:#{set_name}:results:#{set_test}", -1, guid)
      Redis.new(new_app.db).del("#{set_app}:test:#{set_name}:#{set_test}:start")
    end
  end
end

After('@tests') do |scenario|
puts 'After tests'
puts "#{set_app}:test:#{set_name}:#{set_test}:start"
  SnapshotComparer::Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  storage_info = SnapshotComparer::Apps::Bootstrap.storage_info
  FileUtils.rm_rf("#{storage_info['path']}/#{storage_info['prefix']}/#{set_app}/#{set_name}/results/#{set_test}/#{guid}")
  app = SnapshotComparer::Apps::Bootstrap.application_list.find {|a| a[:id] == set_app}
  if app
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    if new_app
      Redis.new(new_app.db).del("#{set_app}:test:#{set_name}:#{set_test}:start")
    end
  end
end
