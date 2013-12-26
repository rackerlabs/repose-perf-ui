When(/^I upload "(.*?)" config file to "(.*?)" "(.*?)" application$/) do |config_name, application, name|
  Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app 
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    fs_ip = new_app.fs_ip
  end

  path = "/#{application}/applications/#{name}/update"
  visit path
  attach_file("upload_config", config_name)
  click_on("upload_config_button")
end

When(/^I upload "(.*?)" test file$/) do |file_name|
  attach_file("upload_test_file", file_name)
  click_on("upload_test_file_button")
end

When(/^I remove "(.*?)" config file$/) do |config_name|
  check config_name
  click_on("remove_configs_button")
end

When(/^I remove "(.*?)" test file from "(.*?)" "(.*?)" application$/) do |file_name, application, name|
  Apps::Bootstrap.main_config(ENV['RACK_ENV'].to_sym)
  app = Apps::Bootstrap.application_list.find {|a| a[:id] == application}
  if app 
    new_app = app[:klass].new(ENV['RACK_ENV'].to_sym)
    fs_ip = new_app.fs_ip
  end

  path = "/#{application}/applications/#{name}/update"
  visit path
  check file_name
  click_on("remove_test_file_button")
end

Then /^the page should contain "([^\"]*)" applications$/ do |app_list|
  app_list.split(',').each do |app|
    page.has_xpath?('.//h4.list-group-item-heading', :text => app)
  end
end

Then /^the page should contain "([^\"]*)" configuration$/ do |config_list|
  config_list.split(',').each do |config|
    page.has_xpath?('.//h4.list-group-item-heading', :text => config)
  end
end

Then(/^download file name should be "(.*?)"$/) do |name|
  page.response_headers['Content-Disposition'].should =~ /#{name}/
end

