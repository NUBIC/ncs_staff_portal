Feature: Manage outreach_events
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new outreach_event
    Given outreach event with race "White" and "Native Hawaiian or Other Pacific Islander" and "Multi-Racial"
    # Given I am on the new outreach_event page
    # When I follow "Edit"
     And I uncheck "White"
     And I check "American Indian or Alaska Native"
     And I check "Asian"
     And I press "Save"
     Then I should see "Native Hawaiian or Other Pacific Islander"
     And I should see "Multi-Racial"
     And I should see "American Indian or Alaska Native"
     And I should see "Asian"
    
    
    # Scenario: Register edit outreach_event
    #   Given the following outreach_events:
    #     |event_date|mode_code|mode_other|outreach_type_code|outreach_type_other|tailored_code|language_specific_code|language_code|language_other|race_specific_code|culture_specific_code|culture_code|culture_other|quantity|cost|no_of_staff|evaluation_result_code|
    #     |event_date 1|mode_code 1|mode_other 1|outreach_type_code 1|outreach_type_other 1|tailored_code 1|language_specific_code 1|language_code 1|language_other 1|race_specific_code 1|culture_specific_code 1|culture_code 1|culture_other 1|quantity 1|cost 1|no_of_staff 1|evaluation_result_code 1|
    #   When I check "White"
    #   And I check "Black or African American"
    #   And I uncheck ""
    # 
    #   And I press "Create"
    #   Then I should see "event_date 1"

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
  # Scenario: Delete outreach_event
  #     Given the following outreach_events:
  #       |event_date|mode_code|mode_other|outreach_type_code|outreach_type_other|tailored_code|language_specific_code|language_code|language_other|race_specific_code|culture_specific_code|culture_code|culture_other|quantity|cost|no_of_staff|evaluation_result_code|
  #       |event_date 1|mode_code 1|mode_other 1|outreach_type_code 1|outreach_type_other 1|tailored_code 1|language_specific_code 1|language_code 1|language_other 1|race_specific_code 1|culture_specific_code 1|culture_code 1|culture_other 1|quantity 1|cost 1|no_of_staff 1|evaluation_result_code 1|
  #       |event_date 2|mode_code 2|mode_other 2|outreach_type_code 2|outreach_type_other 2|tailored_code 2|language_specific_code 2|language_code 2|language_other 2|race_specific_code 2|culture_specific_code 2|culture_code 2|culture_other 2|quantity 2|cost 2|no_of_staff 2|evaluation_result_code 2|
  #       |event_date 3|mode_code 3|mode_other 3|outreach_type_code 3|outreach_type_other 3|tailored_code 3|language_specific_code 3|language_code 3|language_other 3|race_specific_code 3|culture_specific_code 3|culture_code 3|culture_other 3|quantity 3|cost 3|no_of_staff 3|evaluation_result_code 3|
  #       |event_date 4|mode_code 4|mode_other 4|outreach_type_code 4|outreach_type_other 4|tailored_code 4|language_specific_code 4|language_code 4|language_other 4|race_specific_code 4|culture_specific_code 4|culture_code 4|culture_other 4|quantity 4|cost 4|no_of_staff 4|evaluation_result_code 4|
  #     When I delete the 3rd outreach_event
  #     Then I should see the following outreach_events:
  #       |Event date|Mode code|Mode other|Outreach type code|Outreach type other|Tailored code|Language specific code|Language code|Language other|Race specific code|Culture specific code|Culture code|Culture other|Quantity|Cost|No of staff|Evaluation result code|
  #       |event_date 1|mode_code 1|mode_other 1|outreach_type_code 1|outreach_type_other 1|tailored_code 1|language_specific_code 1|language_code 1|language_other 1|race_specific_code 1|culture_specific_code 1|culture_code 1|culture_other 1|quantity 1|cost 1|no_of_staff 1|evaluation_result_code 1|
  #       |event_date 2|mode_code 2|mode_other 2|outreach_type_code 2|outreach_type_other 2|tailored_code 2|language_specific_code 2|language_code 2|language_other 2|race_specific_code 2|culture_specific_code 2|culture_code 2|culture_other 2|quantity 2|cost 2|no_of_staff 2|evaluation_result_code 2|
  #       |event_date 4|mode_code 4|mode_other 4|outreach_type_code 4|outreach_type_other 4|tailored_code 4|language_specific_code 4|language_code 4|language_other 4|race_specific_code 4|culture_specific_code 4|culture_code 4|culture_other 4|quantity 4|cost 4|no_of_staff 4|evaluation_result_code 4|
  