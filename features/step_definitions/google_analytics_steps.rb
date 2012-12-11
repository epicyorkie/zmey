Given /^a website without tracking code$/ do
  @website = websites(:guitar_gear)
  @website.google_analytics_code = ''
  @website.save
end

Given /^a website with tracking code$/ do
  @website = websites(:guitar_gear)
  @website.google_analytics_code = 'UA-000000-1'
  @website.save
end

Then /^I should find the correct tracking code$/ do
  page.html.should match(websites(:guitar_gear).google_analytics_code)
end

Then /^I should not find tracking code$/ do
  page.html.should_not match('google-analytics.com')
end