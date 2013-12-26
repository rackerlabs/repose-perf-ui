Then /^the page should contain "([^\"]*)" test types$/ do |app_list|
  app_list.split(',').each {|app| expect(page).to have_content app }
end
