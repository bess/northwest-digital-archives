Feature: Display Pullman Archives files correctly

	Scenario: Check to see that all of the Pullman Archives are loaded
	Given I am on the homepage
	When I follow "City of Pullman Collection"
	Then I should see 1275 results

	Scenario: Check to see that a record has all its fields
      Given I am on the document page for id pullman_7
	  Then I should see a title of "Olympic Highway ca. 1915"
	  And I should see a "Description" of "A photo showing the old Olympic Highway."
	  And I should see a "Collection" of "City of Pullman Collection"
	  And I should see a "Date" of "ca. 1909"
	

