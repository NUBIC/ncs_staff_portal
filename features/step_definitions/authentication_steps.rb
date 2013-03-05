Given /^I log out/ do
  steps %Q{
    Given I follow "logout"
  }
end

Given /^I log in as "([^"]*)"$/ do |username|
  @current_user = Aker::User.new(username, "NCSNavigator")
  steps %Q{
    Given I am on login
    And I fill in "username" with "#{username}"
    And I fill in "password" with "#{username}"
    And I press "Log in"
  }
end

Given /^an authenticated user$/ do
  header 'Accept', 'text/html'
  username = "superuser"
  staff = Staff.create(:username => username, :email => "#{username}@test.com", :first_name => username, :last_name => username)
  steps %Q{
    Given I log in as "#{username}"
  }
end

Given /I am using the basic credentials "([^\"]*)" \/ "([^\"]*)"$/ do |username, password|
  header "Authorization", "Basic #{["#{username}:#{password}"].pack("m0*")}".strip
end

Given /^the Cases machine account is "(.*?)" \/ "(.*?)"$/ do |username, password|
  NcsNavigator.configuration.core_machine_account_username = username
  NcsNavigator.configuration.core_machine_account_password = password
end

When /^an application authenticates as "(.*?)" \/ "(.*?)"$/ do |username, password|
  step %Q{I am using the basic credentials "#{username}" / "#{password}"}
end

Then /^the request is successful$/ do
  last_response.status.should == 200
end

Then /^not found$/ do
  last_response.status.should == 404
end

Then /^access is forbidden$/ do
  last_response.status.should == 403
end

Then /^unauthorized access$/ do
  last_response.status.should == 401
end
