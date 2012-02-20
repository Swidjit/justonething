Feature: Delete a Want-it
  As a User
  In order to remove a Want It that I no longer want
  I want to delete a Want-it I've posted

  Scenario: User can Post a Want-it
    Given I am logged in
    When I visit a Want It I posted
    And I click delete
    Then the Want It should be deleted