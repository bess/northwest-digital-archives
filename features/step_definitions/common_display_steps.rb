# Display features that all kinds of items should have

Then /^I should see a title of "([^\"]*)"$/ do |title|
  response.should have_tag("h1", :text => title)
end

Then /^I should see a byline of "([^\"]*)"$/ do |byline|
  response.should have_tag("h3.byline", :text => byline)
end

Then /^I should see ([^\"]*) results$/ do |results|
  response.should have_tag("h2#results_label", :text => /^#{results}*/)
end

Then /^I should see a "([^\"]*)" of "([^\"]*)"$/ do |key, value|
  response.should have_tag("dl.defList dt", :text => key)
  response.should have_tag("dl.defList dd", :text => value)
end

Then /^I should not see a "([^\"]*)" field$/ do |key|
  response.should_not have_tag("dl.defList dt", :text => key)
end