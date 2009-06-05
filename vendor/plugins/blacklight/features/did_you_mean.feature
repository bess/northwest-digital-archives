Feature: Did You Mean
  As a user
  In order to get great search results
  I want to get "did you mean" suggestions for poor queries
  
  Scenario: No Results - "All Fields"
    Given the application is configured to have searchable fields "All Fields, Title, Author"
    When I am on the home page
    And I fill in "q" with "boo"
    And I select "All Fields" from "qt"
    And I press "search"
    Then I should see "Did you mean"
    When I follow "book"
    Then I should get results
  
  Scenario: No Results - Title search
    Given the application is configured to have searchable fields "All Fields, Title, Author"
    When I am on the home page
    # yehudiyam is one letter away from a title word
    And I fill in "q" with "yehudiyam"
    And I select "Title" from "qt"
    And I press "search"
    Then I should see "Did you mean"
    When I follow "yehudiyim"
    Then I should get results
    # TODO:  it should be an title search, but I can't get step def right
    #  (it works in the code)
  
  Scenario: No Results - Author search
    Given the application is configured to have searchable fields "All Fields, Title, Author"
    When I am on the home page
    # shirma is one letter away from a title word
    And I fill in "q" with "shirma"
    And I select "Author" from "qt"
    And I press "search"
    Then I should see "Did you mean"
    When I follow "sharma"
    Then I should get results
    # TODO:  it should be an author search, but I can't get step def right
    #  (it works in the code)
  
  Scenario: No Results - and no close spelling suggestions
    Given the application is configured to have searchable fields "All Fields, Title, Author"
    When I am on the home page
    And I fill in "q" with "oofda oofda"
    And I press "search"
    Then I should not see "Did you mean"

  Scenario: No Results - multiword query
    Given the application is configured to have searchable fields "All Fields, Title, Author"
    When I am on the home page
    And I fill in "q" with "boo ya"
    And I select "All Fields" from "qt"
    And I press "search"
    Then I should see "Did you mean"
    When I follow "book bya"
    Then I should get results

  Scenario: Num Results low enough to warrant spelling suggestion
    Given I am on the home page
    # aya gives a single results;  bya gives more
    And I fill in "q" with "aya"
    And I press "search"
    Then I should see "Did you mean"
    When I follow "bya"
    Then I should get results
  
  Scenario: Too many results for spelling suggestion
    Given I am on the home page
    # histori gives 6 results in 30 record demo index
    And I fill in "q" with "histori"
    And I press "search"
    Then I should not see "Did you mean"
  
  Scenario: Exact Threshold number of results for spelling suggestion
    Given I am on the home page
    # histori gives 5 results in 30 record demo index - 5 is default cutoff
    And I fill in "q" with "polit"
    And I press "search"
    Then I should see "Did you mean"
  
