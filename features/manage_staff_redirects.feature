Feature: Manage Redirects after update based on different roles

Scenario: Redirect to staff index page for supervisor update staff
  Given staff with username super11
  And staff member super11 has role "Staff Supervisor"
  And staff with username test111
  When I log in as "super11"
  And I go to the staff edit page for test111
  And I press "Save"
  Then I should be on the manage staff details page
  
Scenario: Redirect to staff page for supervisor update himself
  Given staff with username super11
  And staff member super11 has role "Staff Supervisor"
  When I log in as "super11"
  And I go to the staff edit page for super11
  And I press "Save"
  Then I should be on the staff information page for super11
  
Scenario: Redirect to user list page for user admin update user
  Given staff with username super11
  And staff member super11 has role "User Administrator"
  And staff with username test111
  And staff member test111 has role "Outreach Staff"
  When I log in as "super11"
  And I go to the user edit page for test111
  And I press "Save"
  Then I should be on the manage users accounts page
  
Scenario: Redirect to staff page for user admin update himself as staff
  Given staff with username super11
  And staff member super11 has role "User Administrator"
  When I log in as "super11"
  And I go to the staff edit page for super11
  And I press "Save"
  Then I should be on the staff information page for super11
  
Scenario: Redirect to user list page for user admin update himself as user
  Given staff with username super11
  And staff member super11 has role "User Administrator"
  When I log in as "super11"
  And I go to the user edit page for super11
  And I press "Save"
  Then I should be on the manage users accounts page

Scenario: Redirect to staff page for staff update on success
  Given staff with username test111
  When I log in as "test111"
  And I go to the staff edit page for test111
  And I press "Save"
  Then I should be on the staff information page for test111
  
Scenario: Redirect to user list page when log in user has staff supervisor and user admin role and update user
  Given staff with username super11
  And staff member super11 has role "User Administrator"
  And staff member super11 has role "Staff Supervisor"
  And staff with username test111
  And staff member test111 has role "Outreach Staff"
  When I log in as "super11"
  And I go to the user edit page for test111
  And I press "Save"
  Then I should be on the manage users accounts page
  
Scenario: Redirect to staff index page when log in user has staff supervisor and user admin role and update staff
  Given staff with username super11
  And staff member super11 has role "User Administrator"
  And staff member super11 has role "Staff Supervisor"
  And staff with username test111
  When I log in as "super11"
  And I go to the staff edit page for test111
  And I press "Save"
  Then I should be on the manage staff details page
  
Scenario: Redirect to user list page when log in user has staff supervisor and user admin role and update himself as user
  Given staff with username super11
  And staff member super11 has role "User Administrator"
  And staff member super11 has role "Staff Supervisor"
  When I log in as "super11"
  And I go to the user edit page for super11
  And I press "Save"
  Then I should be on the manage users accounts page
  
Scenario: Redirect to staff page when log in user has staff supervisor and user admin role and update himself as staff
  Given staff with username super11
  And staff member super11 has role "User Administrator"
  And staff member super11 has role "Staff Supervisor"
  When I log in as "super11"
  And I go to the staff edit page for super11
  And I press "Save"
  Then I should be on the staff information page for super11


