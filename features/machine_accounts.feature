Feature: Machine accounts
  In order to support queries from Cases and PSC
  NCS Navigator Ops
  needs to grant permissions to accounts used by machines.

  This feature uses values from the following sources:

  1. spec/machine-users.yml for username/password pairs in test
  2. lib/aker/authorities/machine_accounts.yml.erb for machine

  # See spec/test-users.yml for username / password pairs.
  Scenario: The PSC -> Ops user can retrieve user data
    When an application authenticates as "psc_application" / "psc_application"
    And sends a GET request for "/users.json"

    Then the request is successful

  Scenario: Roles are supplied for the Cases -> PSC user
    When an application authenticates as "ncs_navigator_cases_test" / "ncs_navigator_cases_test"
    And sends a GET request for "/staff/ncs_navigator_cases_test.json"

    Then the request is successful
    And the response contains the roles
      | Field Staff |
      | Phone Staff |

  # Numeric IDs of machine accounts can be found in
  # lib/aker/authorities/machine_accounts.yml.erb.
  Scenario: The Cases -> PSC user can be found by its numeric ID
    When an application authenticates as "ncs_navigator_cases_test" / "ncs_navigator_cases_test"
    And sends a GET request for "/staff/-2.json"

    Then the request is successful
    And the response contains the roles
      | Field Staff |
      | Phone Staff |
