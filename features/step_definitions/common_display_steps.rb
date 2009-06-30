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

Then /^I should see a search result heading for "([^\"]*)"$/ do |title|
  response.should have_tag("h3.index_title", :text => /^\d(.*)#{title}$/)
end

Then /^I should see a search results value "([^\"]*)" of "([^\"]*)"$/ do |key, value|
  response.should have_tag("dl.indexDefList dt", :text => key)
  response.should have_tag("dl.indexDefList dd", :text => value)
end

# This checks for the presence of an h3 element with a value of facet_category, and then 
# separately checks for the presence of a link with value facet_value
# It does not actually check to see that facet_value actually occurs underneath a specific
# facet_category -- I couldn't figure out how to do that. 
Then /^I should see a facet category "([^\"]*)" with a link "([^\"]*)"$/ do |facet_category, facet_value|
  response.should have_tag("div#facets h3", :text => facet_category)
  response.should have_tag("div#facets h3 + ul li a[href]", :text => facet_value)
end
