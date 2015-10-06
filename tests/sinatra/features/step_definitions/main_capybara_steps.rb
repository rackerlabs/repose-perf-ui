When /^I navigate to '([^\"]*)'$/ do |path|
    visit path
end

When(/^I click on "([^\"]*)"$/) do |link|
    click_on link
end

When(/^I select "(.*?)" "(.*?)"$/) do |value, node|
  select value, :from => node
end

When(/^I check on "(.*?)"$/) do |value|
  check value
end

Then /^the page response status code should be "([^\"]*)"$/ do |status|
  page.status_code.should == status.to_i
end

Then(/^the page should contain the "(.*?)" link$/) do |link|
  page.has_link? link
end

Then(/^the page should contain the "(.*?)" paragraph$/) do |paragraph|
  page.has_xpath?('.//p', :text => paragraph)
end

Then(/^the page should have "(.*?)" "(.*?)" header$/) do |value, header|
  page.response_headers[header].should == value
end

Then(/^the page should contain "(.*?)"$/) do |text|
  page.should have_content(text)
end

Then(/^the page source should contain "(.*?)"$/) do |text|
  page.source.should include(text)
end

Then(/^the page should not contain "(.*?)"$/) do |text|
  page.should_not have_content(text)
end

Then(/^the page source should not contain "(.*?)"$/) do |text|
  page.source.should_not include(text)
end

Then /^the error page should match the "([^\"]*)"$/ do |error|
  page.should have_content(error)
end
