Feature: Manage staff_languages
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new staff_language
    Given I am on the new staff_language page
    When I fill in "Staff" with "13"
    And I fill in "Lang code" with "22"
    And I press "Save"
    Then I should see "13"
    And I should see "22"

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
  # Scenario: Delete staff_language
  #   Given the following staff_languages:
  #     |staff_id|lang_code|
  #     |staff_id 1|lang_code 1|
  #     |staff_id 2|lang_code 2|
  #     |staff_id 3|lang_code 3|
  #     |staff_id 4|lang_code 4|
  #   When I delete the 3rd staff_language
  #   Then I should see the following staff_languages:
  #     |Staff|Lang code|
  #     |staff_id 1|lang_code 1|
  #     |staff_id 2|lang_code 2|
  #     |staff_id 4|lang_code 4|
