Feature: Manage staff_cert_trainings
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new staff_cert_training
    Given I am on the new staff_cert_training page
    When I fill in "Certificate type code" with "certificate_type_code 1"
    And I fill in "Complete code" with "complete_code 1"
    And I fill in "Cert date" with "cert_date 1"
    And I fill in "Background check code" with "background_check_code 1"
    And I fill in "Frequency" with "frequency 1"
    And I fill in "Expiration date" with "expiration_date 1"
    And I press "Create"
    Then I should see "certificate_type_code 1"
    And I should see "complete_code 1"
    And I should see "cert_date 1"
    And I should see "background_check_code 1"
    And I should see "frequency 1"
    And I should see "expiration_date 1"

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
  Scenario: Delete staff_cert_training
    Given the following staff_cert_trainings:
      |certificate_type_code|complete_code|cert_date|background_check_code|frequency|expiration_date|
      |certificate_type_code 1|complete_code 1|cert_date 1|background_check_code 1|frequency 1|expiration_date 1|
      |certificate_type_code 2|complete_code 2|cert_date 2|background_check_code 2|frequency 2|expiration_date 2|
      |certificate_type_code 3|complete_code 3|cert_date 3|background_check_code 3|frequency 3|expiration_date 3|
      |certificate_type_code 4|complete_code 4|cert_date 4|background_check_code 4|frequency 4|expiration_date 4|
    When I delete the 3rd staff_cert_training
    Then I should see the following staff_cert_trainings:
      |Certificate type code|Complete code|Cert date|Background check code|Frequency|Expiration date|
      |certificate_type_code 1|complete_code 1|cert_date 1|background_check_code 1|frequency 1|expiration_date 1|
      |certificate_type_code 2|complete_code 2|cert_date 2|background_check_code 2|frequency 2|expiration_date 2|
      |certificate_type_code 4|complete_code 4|cert_date 4|background_check_code 4|frequency 4|expiration_date 4|
