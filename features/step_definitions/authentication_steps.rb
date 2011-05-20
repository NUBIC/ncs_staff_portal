Given /^I log in as "([^\"]*)"$/ do |netid|
  visit "/login"
  fill_in :username, :with => netid
  fill_in :password, :with => "superuser"
  click_button "Log in"
end

# Given /^"([^"]*)" is not an admin$/ do |netid|
#   Bcsec.authority.find_user(netid).permit?(:admin).should be_false
# end