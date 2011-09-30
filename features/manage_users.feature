Feature: Manage Users
  In order to manage users
  As an user administrator
  I want to create and manage users

  Scenario: Users List
    Given an authenticated user 
    And I have users with username user1, user2
    When I go to the list of users
    Then I should see "user1"
    And I should see "user2"