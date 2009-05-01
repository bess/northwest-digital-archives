# Display features that all kinds of items should have

Then /^I should see a title of "([^\"]*)"$/ do |title|
  response.should have_tag("h1", :text => title)
end