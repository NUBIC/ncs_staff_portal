Feature: Manage Staff Details

Scenario: Manage staff details page for supervisor
  Given staff with username super111
  And staff member super111 has role "Staff Supervisor"
  And staff with username test111, test222, test333
  When I log in as "super111"
  And I go to the the manage staff details page
  Then I should see "test222"
  And I should see "test333"
