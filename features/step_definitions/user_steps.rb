Given /^the following users:$/ do |table|
  table.hashes.each do |hash|
    staff = Staff.create!(hash)
  end
end

When /^I send a GET request for "([^\"]*)"$/ do |path|
  header 'Content-Type', 'application/json'
  get path
end


Given /a valid API user with username (.+)$/ do |username|
  Factory(:valid_staff,
    :username => username, :email => "#{username}@test.com",
    :first_name => username, :last_name => username, :study_center => 1234)
  steps %Q{
    Given I am using the basic credentials "#{username}" / "#{username}"
  }
end

Given /a valid API user with default supervisor$/ do
  username = "supervisor"
  Factory(:valid_staff,
    :username => username, :email => "#{username}@test.com",
    :first_name => username, :last_name => username, :study_center => 1234)
  role = Role::STAFF_SUPERVISOR
  steps %Q{
    Given I am using the basic credentials "#{username}" / "#{username}"
    And staff member #{username} has role "#{role}"
  }
end

Given /a valid API user with supervisor role to the staff (.+)$/ do |usernames|
  username = "supervisor"
  staff = Factory(:valid_staff,
    :username => username, :email => "#{username}@test.com",
    :first_name => username, :last_name => username, :study_center => 1234)
  role = Role::STAFF_SUPERVISOR
  steps %Q{
    Given I am using the basic credentials "#{username}" / "#{username}"
    And staff member #{username} has role "#{role}"
  }
  usernames.split(', ').each do |username|
    staff.employees << Factory(:valid_staff,
      :username => username, :email => "#{username}@test.com",
      :first_name => username, :last_name => username, :study_center => 1234)
  end
end

Given /staff with username (.+)$/ do |usernames|
  usernames.split(', ').each do |username|
    Factory(:valid_staff,
      :username => username, :email => "#{username}@test.com",
      :first_name => "fname_" + username, :last_name => "lname_" + username, :study_center => 1234)
    Aker.configuration.authorities.detect { |a| a.is_a?(Aker::Authorities::Static) }.
      valid_credentials!(:user, username, username)
  end
end

Given %r{^staff member (\S+) has role \"([^\"]+)\"$} do |username, role|
  staff = Staff.find_by_username(username)
  staff.should_not be_nil
  role = Role.find_or_create_by_name(role)
  staff.staff_roles.build(:role => role)
  staff.save!
end

Given /^staff member (\S+) has no roles$/ do |username|
  staff = Staff.find_by_username(username)
  staff.should_not be_nil
  staff.staff_roles.clear
  staff.save!
end

Given /^staff member (\S+) is an inactive staff$/ do |username|
  staff = Staff.find_by_username(username)
  staff.should_not be_nil
  staff.ncs_inactive_date = Time.now.to_date - 7.day
  staff.save!
end

Then /has correct JSON response$/ do
  JSON.parse(last_response.body)['username'].should == 'staff'
end
