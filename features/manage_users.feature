@api
Feature: Staff API

  # Scenario: Users List
  #   Given an authenticated user
  #   And I have users with username user1, user2
  #   When I go to the list of users
  #   Then I should see "user1"
  #   And I should see "user2"

  Scenario: Valid authenticated staff can get their own information
    Given a valid API user with username staff
    When I send a GET request for "/staff/staff.json"
    Then the request is successful
    And has correct JSON response

  Scenario: Valid authenticated staff can not get other staff information
    Given a valid API user with username staff1
    And staff with username staff
    When I send a GET request for "/staff/staff.json"
    Then access is forbidden

  Scenario: Valid authenticated default supervisor can see any staff information
    Given staff with username staff
    And a valid API user with default supervisor
    When I send a GET request for "/staff/staff.json"
    Then the request is successful
    And has correct JSON response

  Scenario: Valid authenticated supervisor can see the supervising staff information
    Given a valid API user with supervisor role to the staff staff, staff1
    When I send a GET request for "/staff/staff.json"
    Then the request is successful
    And has correct JSON response

  Scenario: Valid authenticated supervisor can not see othar than supervising staff information
    Given a valid API user with supervisor role to the staff staff, staff1
    And staff with username staff2
    When I send a GET request for "/staff/staff2.json"
    Then access is forbidden

  Scenario: Unauthorized access to get request is not allowed
    And staff with username staff
    When I send a GET request for "/staff/staff.json"
    Then unauthorized access
