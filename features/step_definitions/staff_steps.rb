Given /^the following staff:$/ do |staff|
  Staff.create!(staff.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) staff$/ do |pos|
  visit staff_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following staff:$/ do |expected_staff_table|
  expected_staff_table.diff!(tableish('table tr', 'td,th'))
end