Then /^I should see a list of websites$/ do
  Then "I should see \"#{websites(:guitar_gear).name}\""
  Then "I should see \"#{websites(:website_without_analytics).name}\""
end

Then /^I should see links to edit websites$/ do
  # check one of the websites
  response.should have_xpath("//a[@href='#{edit_website_path(websites(:guitar_gear))}']")
end

Then /^I should see a link to add a new website$/ do
  response.should have_xpath("//a[@href='#{new_website_path}']")
end

Then /^a new website should exist with the domain "([^\"]*)"$/ do |domain|
  Website.find_by_domain(domain).should_not be_nil
end

