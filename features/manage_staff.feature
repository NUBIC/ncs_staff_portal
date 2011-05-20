Feature: Manage staff
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new staff with all required fields
    Given I am on the new staff page
    When I fill in "Name" with "name 1"
    And I fill in "Email" with "email@test.com"
    And I fill in "Netid" with "netid 1"
    And I fill in "Study center" with "1"
    And I select "Field Staff" from "Staff Type"
    And I press "Save"
    Then I should see "name 1"
    And I should see "email@test.com"
    And I should see "netid 1"
    And I should see "1"
    And I should see "Field Staff"
    
  Scenario: Register new staff with all fields
    Given I am on the new staff page
    When I fill in "Name" with "name 1"
    And I fill in "Email" with "email@test.com"
    And I fill in "Netid" with "netid 1"
    And I fill in "Study center" with "1"
    And I select "Field Staff" from "Staff Type"
    And I fill in "Other staff type" with "new type"
    And I fill in "Year of birth" with "1995"
    And I select "Less than 18" from "Age range"
    And I select "Female" from "Gender"
    And I select "Asian" from "Race"
    And I fill in "Other race type" with "new race type"
    And I select "Refused" from "Ethnicity"
    And I select "Yes" from "Does staff member work for subcontrator"
    And I select "Less than 1 year" from "Direct experience conducting population based, household field interviewing"
    And I press "Save"
    Then I should see "name 1"
    And I should see "email@test.com"
    And I should see "netid 1"
    And I should see "1"
    And I should see "Field Staff"
    And I should see "new type"
    And I should see "1995"
    And I should see "Female"
    And I should see "Asian"
    And I should see "new race type"
    And I should see "Yes"
    And I should see "Less than 1 year"
    
  Scenario: Register new staff with lanuguages
    Given I am on the new staff page
    When I fill in "Name" with "name 1"
    And I fill in "Email" with "email@test.com"
    And I fill in "Netid" with "netid 1"
    And I fill in "Study center" with "1"
    And I select "Field Staff" from "Staff Type"
    And I select "English" from "Language"
    And I press "Save"
    Then I should see "name 1"
    And I should see "email@test.com"
    And I should see "netid 1"
    And I should see "1"
    And I should see "Field Staff"

    
  # Rails generates Delete links that use Javascript to pop up a confirmation
  # dialog and then do a HTTP POST request (emulated DELETE request).
  #
  # Capybara must use Culerity/Celerity or Selenium2 (webdriver) when pages rely
  # on Javascript events. Only Culerity/Celerity supports clicking on confirmation
  # dialogs.
  #
  # Since Culerity/Celerity and Selenium2 has some overhead, Cucumber-Rails will
  # detect the presence of Javascript behind Delete links and issue a DELETE request 
  # instead of a GET request.
  #
  # You can turn this emulation off by tagging your scenario with @no-js-emulation.
  # Turning on browser testing with @selenium, @culerity, @celerity or @javascript
  # will also turn off the emulation. (See the Capybara documentation for 
  # details about those tags). If any of the browser tags are present, Cucumber-Rails
  # will also turn off transactions and clean the database with DatabaseCleaner 
  # after the scenario has finished. This is to prevent data from leaking into 
  # the next scenario.
  #
  # Another way to avoid Cucumber-Rails' javascript emulation without using any
  # of the tags above is to modify your views to use <button> instead. You can
  # see how in http://github.com/jnicklas/capybara/issues#issue/12
  #
  # Scenario: Delete staff
  #   Given the following staffs:
  #     |name|email|netid|study_center|type_code|
  #     |name 1|email 1|netid 1|study_center 1|type_code 1|
  #     |name 2|email 2|netid 2|study_center 2|type_code 2|
  #     |name 3|email 3|netid 3|study_center 3|type_code 3|
  #     |name 4|email 4|netid 4|study_center 4|type_code 4|
  #   When I delete the 3rd staff
  #   Then I should see the following staffs:
  #     |Name|Email|Netid|Study center|Type code|
  #     |name 1|email 1|netid 1|study_center 1|type_code 1|
  #     |name 2|email 2|netid 2|study_center 2|type_code 2|
  #     |name 4|email 4|netid 4|study_center 4|type_code 4|
