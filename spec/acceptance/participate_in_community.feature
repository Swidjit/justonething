Feature: Participate in Community
  As a User
  In order to interact with other people
  I want to join and post items to a Community

  Scenario: User can join and post an item to a community
    Given I am logged in
    When I visit a Community I didn't create
    Then I should not see a link to post a Want It
    When I click Join
    Then I should see a link to post a Want It
    When I click the link to Post a Want-it
    And I fill out all required fields of the form
    And I submit the form
    Then the Want-it should be posted
    And the Want It should be linked to the Community