require 'json'

temp_results = ''
results = ''

When(/^I post to "([^\"]*)" with "(.*?)"$/) do |path, test_id_list|
  	post(path,{:compare => test_id_list})
end

When /^I navigate to '([^\"]*)'$/ do |path|
  	get path
end

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
  results['results'].length.should == count.to_i
end

Then(/^there should be "(\d+)" "(\w+)" records in response$/) do |count, type|
  results = JSON.parse(last_response.body)
  if count.to_i == 0
    results[type].should == nil
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
  results[key] == value
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

Then /^the page should contain "([^\"]*)" applications$/ do |app_list|
	app_found = true
	app_list.split(',').each do |app|
		app_found = last_response.body.include?(app)
		break unless app_found
	end

	app_found.should == true
end

Then /^the page should contain "([^\"]*)" configuration$/ do |config_list|
	config_found = true
	config_list.split(',').each do |config|
		config_found = last_response.body.include?(config)
		break unless config_found
	end

	config_found.should == true
end

Then /^the page should contain "([^\"]*)" test types$/ do |test_type_list|
	test_type_found = true
	test_type_list.split(',').each do |test_type|
		test_type_found = last_response.body.include?(test_type)
		break unless test_type_found
	end

	test_type_found.should == true
end

Then /^the download page should match the "([^\"]*)" version$/ do |runner|
	result = File.read(File.join(File.dirname(__FILE__), '..', "views/#{runner}.runner"))
	last_response.body.should == result
end

Then /^the error page should match the "([^\"]*)"$/ do |error|
	last_response.body.should == error
end