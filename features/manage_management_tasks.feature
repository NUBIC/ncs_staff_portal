Feature: Manage management_tasks
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new management_task
    Given I am on the new management_task page
    When I fill in "Task type code" with "task_type_code 1"
    And I fill in "Task type other" with "task_type_other 1"
    And I fill in "Task hours" with "task_hours 1"
    And I fill in "Comment" with "comment 1"
    And I press "Create"
    Then I should see "task_type_code 1"
    And I should see "task_type_other 1"
    And I should see "task_hours 1"
    And I should see "comment 1"

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
  Scenario: Delete management_task
    Given the following management_tasks:
      |task_type_code|task_type_other|task_hours|comment|
      |task_type_code 1|task_type_other 1|task_hours 1|comment 1|
      |task_type_code 2|task_type_other 2|task_hours 2|comment 2|
      |task_type_code 3|task_type_other 3|task_hours 3|comment 3|
      |task_type_code 4|task_type_other 4|task_hours 4|comment 4|
    When I delete the 3rd management_task
    Then I should see the following management_tasks:
      |Task type code|Task type other|Task hours|Comment|
      |task_type_code 1|task_type_other 1|task_hours 1|comment 1|
      |task_type_code 2|task_type_other 2|task_hours 2|comment 2|
      |task_type_code 4|task_type_other 4|task_hours 4|comment 4|
