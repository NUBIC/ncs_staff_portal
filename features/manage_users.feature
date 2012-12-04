@api
Feature: Users API

  Scenario: Valid authenticated staff can get their own information
    Given a valid API user with username staff
    When I send a GET request for "/staff/staff.json"
    Then the request is successful
    And has correct JSON response

  Scenario: Valid authenticated staff get 404 if user is unknown
    Given a valid API user with default supervisor
    When I send a GET request for "/staff/unknown.json"
    Then not found

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
    Given staff with username staff
    When I send a GET request for "/staff/staff.json"
    Then unauthorized access

  Scenario: Valid authenticated user administrator can get all the staff in the system
    Given a valid API user with username superuser
    And staff member superuser has role "User Administrator"
    And staff with username test1
    And staff with username test2
    And staff with username test3
    When I send a GET request for "/users.json"
    Then the request is successful
    And the JSON should have 4 user

  Scenario: Access to get users request by the user with role other than User Administrator is not allowed
    Given a valid API user with username staff
    And staff member staff has role "Staff Supervisor"
    When I send a GET request for "/users.json"
    Then access is forbidden

  Scenario: Valid authenticated user administrator can get all the staff by role with single role
    Given a valid API user with username superuser
    And staff member superuser has role "User Administrator"
    And staff with username test1
    And staff member test1 has role "Phone Staff"
    And staff with username test2
    And staff member test2 has role "Phone Staff"
    And staff with username test3
    And staff member test3 has role "Field Staff"
    When I send a GET request for "/users.json?role%5B%5D=Phone%20Staff"
    Then the request is successful
    And the JSON should have 2 user

  Scenario: Valid authenticated user administrator can get all the staff by role with multiple roles
    Given a valid API user with username superuser
    And staff member superuser has role "User Administrator"
    And staff with username test1
    And staff member test1 has role "Phone Staff"
    And staff with username test2
    And staff member test2 has role "Outreach Staff"
    And staff with username test3
    And staff member test3 has role "Field Staff"
    When I send a GET request for "/users.json?role%5B%5D=Phone%20Staff&role%5B%5D=Field%20Staff"
    Then the request is successful
    And the JSON should have 2 user

  Scenario: Valid authenticated user administrator can search the staff by first_name
    Given a valid API user with username superuser
    And staff member superuser has role "User Administrator"
    And staff with username test1
    And staff with username test2
    When I send a GET request for "/users.json?first_name=test1"
    Then the request is successful
    And the JSON should have 1 user
    And the JSON at "0/first_name" should be "fname_test1"

  Scenario: Valid authenticated user administrator can search the staff by last_name
    Given a valid API user with username superuser
    And staff member superuser has role "User Administrator"
    And staff with username test1
    And staff with username test2
    When I send a GET request for "/users.json?last_name=test1"
    Then the request is successful
    And the JSON should have 1 user
    And the JSON at "0/last_name" should be "lname_test1"

  Scenario: Valid authenticated user administrator can search the staff by username
    Given a valid API user with username superuser
    And staff member superuser has role "User Administrator"
    And staff with username test1
    And staff with username test2
    When I send a GET request for "/users.json?username=test1"
    Then the request is successful
    And the JSON should have 1 user
    And the JSON at "0/username" should be "test1"

  Scenario: Valid authenticated user administrator can search the staff by first_name and last_name
    Given a valid API user with username superuser
    And staff member superuser has role "User Administrator"
    And staff with username test1
    And staff with username test2
    When I send a GET request for "/users.json?first_name=fname_test1&last_name=lname_test1"
    Then the request is successful
    And the JSON should have 1 user
    And the JSON at "0/first_name" should be "fname_test1"
    And the JSON at "0/last_name" should be "lname_test1"

  Scenario: Valid authenticated user administrator can search the staff by first_name and username
    Given a valid API user with username superuser
    And staff member superuser has role "User Administrator"
    And staff with username test1
    And staff with username test2
    When I send a GET request for "/users.json?first_name=fname_test1&username=test1"
    Then the request is successful
    And the JSON should have 1 user
    And the JSON at "0/first_name" should be "fname_test1"
    And the JSON at "0/username" should be "test1"

  Scenario: Valid authenticated user administrator can search the staff by last_name and username
    Given a valid API user with username superuser
    And staff member superuser has role "User Administrator"
    And staff with username test1
    And staff with username test2
    When I send a GET request for "/users.json?last_name=lname_test1&username=test1"
    Then the request is successful
    And the JSON should have 1 user
    And the JSON at "0/last_name" should be "lname_test1"
    And the JSON at "0/username" should be "test1"

  Scenario: Valid authenticated user administrator can search the staff by first_name and last_name and username
    Given a valid API user with username superuser
    And staff member superuser has role "User Administrator"
    And staff with username test1
    And staff with username test2
    When I send a GET request for "/users.json?first_name=fname_test1&last_name=lname_test1&username=test1"
    Then the request is successful
    And the JSON should have 1 user
    And the JSON at "0/first_name" should be "fname_test1"
    And the JSON at "0/last_name" should be "lname_test1"
    And the JSON at "0/username" should be "test1"

  Scenario: Valid authenticated user administrator can search the staff by first_name or last_name
    Given a valid API user with username superuser
    And staff member superuser has role "User Administrator"
    And staff with username test1
    And staff with username test2
    When I send a GET request for "/users.json?first_name=fname_test1&last_name=lname_test2&operator=OR"
    Then the request is successful
    And the JSON should have 2 user

  Scenario: Valid authenticated user administrator can search the staff by first_name or username
    Given a valid API user with username superuser
    And staff member superuser has role "User Administrator"
    And staff with username test1
    And staff with username test2
    When I send a GET request for "/users.json?first_name=fname_test1&username=test2&operator=OR"
    Then the request is successful
    And the JSON should have 2 user

  Scenario: Valid authenticated user administrator can search the staff by first_name or last_name or username
    Given a valid API user with username superuser
    And staff member superuser has role "User Administrator"
    And staff with username test1
    And staff with username test2
    And staff with username test3
    When I send a GET request for "/users.json?first_name=fname_test1&last_name=lname_test2&username=test3&operator=OR"
    Then the request is successful
    And the JSON should have 3 user
