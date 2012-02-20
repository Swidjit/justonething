Feature: Edit a Want-it
  As a User
  In order to update information of a  Want It
  I want to be able to edit a Want-it I've posted

  Scenario: User can Edit a Want-it
    Given I am logged in
    When I visit a Want It I posted
    And I click edit
    And I fill out all required fields of the form
    And I click Update
    Then the Want It should be updated