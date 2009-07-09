Feature: Display Herbarium files correctly

	Scenario: Check for presence of correct facets
		Given I am on the homepage
		Then I should see a facet category "Collection" with a link "Oregon State University Herbarium"
		When I follow "Oregon State University Herbarium"
		Then I should see a facet category "Institution" with a link "Oregon State University"

		
		

	
