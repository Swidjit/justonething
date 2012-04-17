Feature: Manage Items
  As a User
  In order to interact with my community
  I want to manage multiple items

  Scenario: User can manage a Want-it
    Given I am logged in
    When I visit the Home Page
    And I click the link to Post a Want-it
    And I fill out all required fields of the form
    And I submit the form
    Then the Want-it should be posted
    And I click edit
    And I change the description
    And I click Update
    Then the Want It should be updated
    And I click delete
    Then the Want It should be deleted

  Scenario: User can manage a Have It
    Given I am logged in
    When I visit the Home Page
    And I click the link to Post a Have It
    And I fill out all required fields of the form
    And I fill out all required fields of the form for a Have It
    And I submit the form
    Then the Have It should be posted
    And I click edit
    And I change the description
    And I click Update
    Then the Have It should be updated
    And I click delete
    Then the Have It should be deleted

  Scenario: User can manage a Link
    Given I am logged in
    When I visit the Home Page
    And I click the link to Post a Link
    And I fill out all required fields of the form
    And I fill out the link field
    And I submit the form
    Then the Link should be posted
    And I click edit
    And I change the description
    And I click Update
    Then the Link should be updated
    And I click delete
    Then the Link should be deleted

  Scenario: User can manage a Thought
    Given I am logged in
    When I visit the Home Page
    And I click the link to Post a Thought
    And I fill out all required fields of the form
    And I submit the form
    Then the Thought should be posted
    And I click edit
    And I change the description
    And I click Update
    Then the Thought should be updated
    And I click delete
    Then the Thought should be deleted

  Scenario: User can manage a Event
    Given I am logged in
    When I visit the Home Page
    And I click the link to Post an Event
    And I fill out all required fields of the form
    And I fill out all required fields of the form for an Event
    And I submit the form
    Then the Event should be posted
    And I click edit
    And I change the description
    And I click Update
    Then the Event should be updated
    And I click delete
    Then the Event should be deleted

  Scenario: User can manage a Collection
    Given I am logged in
    When I visit the Home Page
    And I click the link to Post a Collection
    And I fill out all required fields of the form
    And I submit the form
    Then the Collection should be posted
    And I click edit
    And I change the description
    And I click Update
    Then the Collection should be updated
    And I click delete
    Then the Collection should be deleted