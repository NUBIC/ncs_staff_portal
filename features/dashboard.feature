Feature: Dashboard

Scenario Outline: Default page for various roles
  Given staff with username zw108
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

@wip
Scenario: Default page for a staff member with no roles
  Given staff with username zw108
    And zw108 has no roles
   When I go to the default page
    And I log in as "zw108"
   Then I should be on the staff information page for zw108
