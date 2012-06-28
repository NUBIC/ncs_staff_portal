Feature: Dashboard

Scenario Outline: Default page for various roles
  Given staff with name zw108
    And staff member zw108 has role "<role>"
   When I go to the default page
    And I log in as "zw108"
   Then I should be on <page> for zw108

  Examples:
    | role                          | page                              |
    | Field Staff                   | a data collection task entry page |
    | Phone Staff                   | a data collection task entry page |
    | Biological Specimen Collector | a data collection task entry page |
    | Specimen Processor            | a data collection task entry page |
    | System Administrator          | a management task entry page      |
    | User Administrator            | a management task entry page      |
    | Staff Supervisor              | a management task entry page      |
    | Outreach Staff                | a management task entry page      |
    | Administrative Staff          | a management task entry page      |
    | Data Reader                   | the staff information page        |

Scenario: Default page for a staff member with no roles
  Given staff with name zw108
    And staff member zw108 has no roles
   When I go to the default page
    And I log in as "zw108"
   Then I should be on the default page for staff without role
