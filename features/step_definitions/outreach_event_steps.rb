Given /^the following outreach_events:$/ do |outreach_events|
  OutreachEvent.create!(outreach_events.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) outreach_event$/ do |pos|
  visit outreach_events_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following outreach_events:$/ do |expected_outreach_events_table|
  expected_outreach_events_table.diff!(tableish('table tr', 'td,th'))
end


Given /^outreach event with race "([^"]*)" and "([^"]*)" and "([^"]*)"$/ do |r1, r2, r3|
  visit new_outreach_event_path
    check(r1)
    check(r2)
    check(r3)
  click_button("Save")
  within(".action") do
    click_link "Edit"
  end
end

# When /^I edit the (\d+)(?:st|nd|rd|th) outreach_event$/ do |pos|
#   visit outreach_events_path
#   within("table tr:nth-child(#{pos.to_i+1})") do
#      click_link "Edit"
#   end
# end

