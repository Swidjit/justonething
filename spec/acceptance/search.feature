Feature: Do Search
  As a User
  In order to find items
  I want to search the site

  Scenario: User can search
    When I visit the Home Page
    And I submit a search that matches an item
    Then the search should return valid results
