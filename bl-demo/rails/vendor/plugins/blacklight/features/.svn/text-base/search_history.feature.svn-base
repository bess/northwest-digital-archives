Feature: Search History Page
  As a user
  In order see searches I've used and reuse them
  I want a page that shows my (unique) search history from this session
  
  Scenario: Menu Link
    When I am on the home page
    Then I should see "Search History"
    When I follow "Search History"
    Then I should be on the search history page
  
  Scenario: No Searches
    Given no previous searches
    When I go to the search history page
    Then I should see "You have no search history"
    
  Scenario: Searches
    Given I have done a search with term "book"
    When I go to the search history page
    Then I should see "Your recent searches"
    And I should see "book"
    
  Scenario: Deleting a Search
    Given I have done a search with term "book"
    And I am on the search history page
    Then I should see "delete"
    When I follow "delete"
    Then I should see "Successfully removed that search history item."

  Scenario: Clearing Search History
    Given I have done a search with term "book"
    And I have done a search with term "dang"
    And I am on the search history page
    Then I should see "Clear Search History"
    When I follow "Clear Search History"
    Then I should see "Cleared your search history."
    And I should see "You have no search history"

