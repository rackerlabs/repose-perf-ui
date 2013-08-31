require 'json'



When /^I navigate to '([^\"]*)'$/ do |path|
  	get path
end

When /^I click on '([^\"]*)'$/ do |path|
  	get path
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

Then(/^there should be "(.*?)" records in response$/) do |count|
  results = JSON.parse(last_response.body)
  results['results'].length.should == count.to_i
end

Then(/^the test should have ended$/) do
  results = JSON.parse(last_response.body)
  results['ended'].should == true
end

Then(/^the test should not have ended$/) do
  results = JSON.parse(last_response.body)
  results['ended'].should == false
end

Then /^the page should match the "([^\"]*)" version$/ do |template|
	result = File.read(File.join(File.dirname(__FILE__), '..', "views/#{template}.html"))
	last_response.body.should == result
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