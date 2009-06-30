Feature: Display Pullman Archives files correctly

	Scenario: Check to see that all of the Pullman Archives are loaded
		Given I am on the homepage
		When I follow "City of Pullman Collection"
		Then I should see 1275 results
		When I follow "Less than 10 years old"
		Then I should see 365 results
	
	Scenario: Check for presence of correct facets
		Given I am on the homepage
		Then I should see a facet category "Collection" with a link "City of Pullman Collection"
		Then I should see a facet category "Institution" with a link "Washington State University"
	
	Scenario: Search for Palouse
		Given I am on the homepage
		When I fill in "q" with "Palouse"
		And I press "search"
		Then I should see 393 results
	
	Scenario: Search for Paul Henning Collection
	  Given I am on the homepage
	  When I fill in "q" with '"Paul Henning Collection"'
	  And I press "search"
	  Then I should see 365 results
	
	Scenario: Search for string Theater in Pullman (no quotes)
	  Given I am on the homepage
	  When I fill in "q" with "Theater in Pullman"
	  And I press "search"
	  Then I should see 8 results
	
	Scenario: Search for phrase "Theater in Pullman"
	  Given I am on the homepage
	  When I fill in "q" with '"Theater in Pullman"'
	  And I press "search"
	  Then I should see 2 results
	
	Scenario: Check to see that a record has all its fields
      Given I am on the document page for id pullman_7
	  Then I should see a title of "Olympic Highway ca. 1915"
	  And I should see a "Description" of "A photo showing the old Olympic Highway."
	  And I should see a "Collection" of "City of Pullman Collection"
	  And I should see a "Date" of "ca. 1915"
	

	Scenario: A record without a date
      Given I am on the document page for id pullman_9
	  Then I should see a title of "Washington Hotel, Pullman"
	  And I should see a "Description" of "The Washington Hotel."
	  And I should see a "Collection" of "City of Pullman Collection"
	  And I should not see a "Date" field
	
	
	Scenario: A record without a description
      Given I am on the document page for id pullman_1495
	  Then I should see a title of "Leonard Bros and Co., Uniontown, 2003"
	  And I should not see a "Description" field	  
	  And I should see a "Collection" of "City of Pullman Collection"
	  And I should see a "Date" of "June 16, 2003"
	  And I should see a "Source" of "Paul Henning Collection: Historic Architecture of the Palouse"
	
	
	
	
	
