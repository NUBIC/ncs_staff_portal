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
  staff = Staff.create!(:username => username, :email => "#{username}@test.com", :first_name => username, :last_name => username, :study_center => 1234)
  steps %Q{
    Given I am using the basic credentials "#{username}" / "#{username}"
  }
end

Given /a valid API user with default supervisor$/ do
  username = "supervisor"
  staff = Staff.create!(:username => username, :email => "#{username}@test.com", :first_name => username, :last_name => username, :study_center => 1234)
  role = Role.find_by_name(Role::STAFF_SUPERVISOR)
  role = Role.create(:name => Role::STAFF_SUPERVISOR) unless role
  staff.roles << role
  steps %Q{
    Given I am using the basic credentials "#{username}" / "#{username}"
  }
end

Given /a valid API user with supervisor role to the staff (.+)$/ do |usernames|
  supervisor = "supervisor"
  staff = Staff.create!(:username => supervisor, :email => "#{supervisor}@test.com", :first_name => supervisor, :last_name => supervisor, :study_center => 1234)
  role = Role.find_by_name(Role::STAFF_SUPERVISOR)
  role = Role.create(:name => Role::STAFF_SUPERVISOR) unless role
  staff.roles << role
  usernames.split(', ').each do |username|
    staff.employees << Staff.create!(:username => username, :email => "#{username}@test.com", :first_name => username, :last_name => username, :study_center => 1234)
  end
  steps %Q{
    Given I am using the basic credentials "#{supervisor}" / "#{supervisor}"
  }
end

Given /staff with username (.+)$/ do |usernames|
  usernames.split(', ').each do |username|
    staff = Staff.create!(:username => username, :email => "#{username}@test.com", :first_name => username, :last_name => username, :study_center => 1234)
  end
end

Then /has correct JSON response$/ do
  JSON.parse(last_response.body)['username'].should == 'staff'
end
