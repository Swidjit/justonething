Feature: Post a Want-it
  As a User
  In order to find people with things I want within a community
  I want to post a Want-it

  Scenario: User can Post a Want-it
    Given I am logged in
    When I visit the Home Page
    And I click the link to Post a Want-it
    And I fill out all required fields of the form
    And I submit the form
    Then the Want-it should be posted