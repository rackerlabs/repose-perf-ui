Then /^the page should contain "([^\"]*)" application list$/ do |app_list|
  app_list.split(',').each {|app| expect(page).to have_content app }
end
