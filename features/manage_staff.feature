Feature: Manage staff
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Delete staff
    Given the following staff:
      |name|email|netid|study_center|
      |name test1|email test1@test1.com|netid test1|study_center 12345|
      |name test2|email test2@test2.com|netid test2|study_center 12345|
      |name test3|email test3@test3.com|netid test3|study_center 12345|
      |name test4|email test4@test4.com|netid test4|study_center 12345|
    When I delete the 3rd staff
    Then I should see the following staff:
      |Name|Email|Netid|Study center|
      |name test1|email test1@test.com|netid test1|study_center 12345|
      |name test2|email test2@test.com|netid test2|study_center 12345|
      |name test4|email test4@test.com|netid test4|study_center 12345|
