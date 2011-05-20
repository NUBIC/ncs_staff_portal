Feature: Manage staff_weekly_expenses
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new staff_weekly_expense
    Given I am on the new staff_weekly_expense page
    # When I select "[date]" as the date
    When I select "[date]" as the "Week start date" date
    And I fill in "Staff pay" with "staff_pay 1"
    And I fill in "Staff hours" with "staff_hours 1"
    And I fill in "Staff expenses" with "staff_expenses 1"
    And I fill in "Staff miles" with "staff_miles 1"
    And I fill in "Comment" with "comment 1"
    And I press "Create"
    Then I should see "December 25, 2010"
    And I should see "staff_pay 1"
    And I should see "staff_hours 1"
    And I should see "staff_expenses 1"
    And I should see "staff_miles 1"
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
  # Scenario: Delete staff_weekly_expense
  #   Given the following staff_weekly_expenses:
  #     |week_start_date|staff_pay|staff_hours|staff_expenses|staff_miles|comment|
  #     |week_start_date 1|staff_pay 1|staff_hours 1|staff_expenses 1|staff_miles 1|comment 1|
  #     |week_start_date 2|staff_pay 2|staff_hours 2|staff_expenses 2|staff_miles 2|comment 2|
  #     |week_start_date 3|staff_pay 3|staff_hours 3|staff_expenses 3|staff_miles 3|comment 3|
  #     |week_start_date 4|staff_pay 4|staff_hours 4|staff_expenses 4|staff_miles 4|comment 4|
  #   When I delete the 3rd staff_weekly_expense
  #   Then I should see the following staff_weekly_expenses:
  #     |Week start date|Staff pay|Staff hours|Staff expenses|Staff miles|Comment|
  #     |week_start_date 1|staff_pay 1|staff_hours 1|staff_expenses 1|staff_miles 1|comment 1|
  #     |week_start_date 2|staff_pay 2|staff_hours 2|staff_expenses 2|staff_miles 2|comment 2|
  #     |week_start_date 4|staff_pay 4|staff_hours 4|staff_expenses 4|staff_miles 4|comment 4|
