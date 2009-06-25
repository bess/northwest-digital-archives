Feature: Display EAD files correctly
  In order to get all relevant information about an EAD guide
  I want to see all of the proper fields from the EAD

  # Scenario: formatting for a typical EAD guide
  #   Given I am on the document page for id 80444_xv94616
  # 	  Then I should see a title of "Guide to Ralph W. Barnes papers"
  # 	  And I should see a byline of "Willamette University Archives and Special Collections"
	  # And I should see a related name of "Evans, David" with no role
	  # And it should have a valid link to delicious bookmarks for id "u4856159"
	
	Scenario: search for "Robert C. Notson"
	  Given I am on the homepage
	  When I fill in "q" with "'Robert C. Notson'"
	  And I press "search"
	  Then I should see 1 results
	  And I should see "Guide to the Robert C. Notson papers"
	
	
	