Feature: Display baseball files correctly

	Scenario: Check to see that all of the baseball records are loaded
		Given I am on the homepage
		When I follow "Oregon State Baseball"
		Then I should see 1634 results
		When I follow "More than 100 years old"
		Then I should see 38 results
	
	Scenario: Search for Harriet's Collection
		Given I am on the homepage
		When I fill in "q" with '"Harriet's Collection"'
		And I press "search"
		Then I should see 136 results
	
	Scenario: Check to see that a record has all its fields
		Given I am on the homepage
		Given I am on the document page for id baseball_467
		Then I should see a title of "Baseball game"
		And I should see a "Source" of "Office of University Publications"
		And I should see a "Collection" of "Oregon State Baseball"
		
	Scenario: more spot checking
		Given I am on the document page for id baseball_78
		Then I should see a title of "JHH Baseball Team"
		And I should see a "Description" of "JHH Team"
		And I should see a "Date" of "1892"
		And I should see a "Contributor(s)" of "Oregon State University Archives"
		
	Scenario: Check for presence of correct facets
		Given I am on the homepage
		Then I should see a facet category "Collection" with a link "Oregon State Baseball"
		When I follow "Oregon State Baseball"
		Then I should see a facet category "Institution" with a link "Oregon State University"
		



		
	# 
	# Scenario: A record without a description
	#       Given I am on the document page for id pullman_1495
	#   Then I should see a title of "Leonard Bros and Co., Uniontown, 2003"
	#   And I should not see a "Description" field	  
	#   And I should see a "Collection" of "City of Pullman Collection"
	#   And I should see a "Date" of "June 16, 2003"
	#   And I should see a "Source" of "Paul Henning Collection: Historic Architecture of the Palouse"
	# 
	# 
	# 
	# 
	# 
