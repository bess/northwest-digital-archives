Feature: Display Pullman Archives files correctly

  Scenario: Check to see that all of the Pullman Archives are loaded
    Given I am on the homepage
	  When I follow "City of Pullman Collection"
	  Then I should see 1275 results
