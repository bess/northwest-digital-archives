Feature: Display WSU theses files correctly

	Scenario: Check for presence of correct facets
		Given I am on the homepage
		Then I should see a facet category "Collection" with a link "Washington State University Theses"
		When I follow "Washington State University Theses"
		Then I should see a facet category "Institution" with a link "Washington State University"
		When I follow "Washington State University"
		Then I should see a facet category "Format" with a link "Thesis"
		And I should see a facet category "Format" with a link "Article"
		
		
		

	
