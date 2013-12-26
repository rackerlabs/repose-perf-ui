Then /^the response should contain "([^\"]*)"$/ do |result|
  last_response.body.include?(result).should be(true)
end

Then /^the response should not contain "([^\"]*)"$/ do |result|
  last_response.body.include?(result).should be(false)
end
