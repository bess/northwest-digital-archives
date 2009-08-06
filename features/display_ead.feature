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
	  Then I should get 1 results
	  And I should see a search result heading for "Robert C. Notson papers"
	  And I should see a search results value "Institution" of "Willamette University Archives and Special Collections"
	
	Scenario: formatting for a guide
		Given I am on the document page for id owsmss001xml-summary
		Then I should see a title of "Robert C. Notson papers::Summary Information"
		And I should see "Biography/History"
	
	Scenario: correct capitalization for sections
		Given I am on the document page for id owsmss007-biography_history
		Then I should see a title of "Freshman Glee records::Historical note"
	
	Scenario: correct facets
		Given I am on the homepage
		When I fill in "q" with "Montana"
		And I press "search"
		And I follow "Montana Historical Society Archives"
		Then I should see a facet category "Availability" with a link "Not online. Must visit contributing institution."

	# KNOWN BUG: Searching with the ampersand in the query will break
	# Scenario: be able to search by institution name
	# 	Given I am on the homepage
	# 	When I fill in "q" with the phrase "Museum of History & Industry"
	# 	And I press "search"
	# 	Then I should get 171 results
	
	Scenario: be able to search by institution name
		Given I am on the homepage
		When I fill in "q" with the phrase "gonzaga"
		And I press "search"
		And I follow "Foley Center Library Special Collections"
		Then I should get 20 results

	Scenario: display rights
		Given I am on the document page for id stevensisaaci111xml-summary
		Then I should see "The creator's literary rights are in the public domain."
		
	Scenario: display right again
		Given I am on the document page for id washingtonterritory4284xml-summary
		Then I should see "Public Records (use unrestricted when access is granted)"

	#Scenario: Pearl Harbor game collection
		#Given I am on the document page for id owsmss9xml-summary
	
	Scenario: abstract display in index
		Given I am on the homepage
		When I fill in "q" with "Leone Cass Baer"
		And I press "search"
		And I should see a search results value "Abstract" of "The collection consists primarily of autographed publicity portraits of music, theater, and movie personalities, given to Leone Cass Baer, ca. 1910-1921, when she was ..."