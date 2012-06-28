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
  staff = valid_staff(username)
  steps %Q{
    Given I am using the basic credentials "#{username}" / "#{username}"
  }
end

Given /a valid API user with default supervisor$/ do
  username = "supervisor"
  staff = valid_staff(username)
  role = Role::STAFF_SUPERVISOR
  steps %Q{
    Given I am using the basic credentials "#{username}" / "#{username}"
    And staff member #{username} has role "#{role}"
  }
end

Given /a valid API user with supervisor role to the staff (.+)$/ do |usernames|
  username = "supervisor"
  staff = valid_staff(username)
  role = Role::STAFF_SUPERVISOR
  steps %Q{
    Given I am using the basic credentials "#{username}" / "#{username}"
    And staff member #{username} has role "#{role}"
  }
  usernames.split(', ').each do |username|
    staff.employees << valid_staff(username)
  end
end

Given /staff with name (.+)$/ do |names|
  names.split(', ').each do |name|
    staff = Factory(:valid_staff, :first_name => name, :last_name => name, :study_center => 1234)
    Aker.configuration.authorities.detect { |a| a.is_a?(Aker::Authorities::Static) }.
      valid_credentials!(:user, name, name)
  end
end

Given /staff with username (.+)$/ do |usernames|
  usernames.split(', ').each do |username|
    staff = valid_staff(username, "true")
    Aker.configuration.authorities.detect { |a| a.is_a?(Aker::Authorities::Static) }.
      valid_credentials!(:user, username, username)
  end
end

Given %r{^staff member (\S+) has role \"([^\"]+)\"$} do |username, role|
  staff = Staff.find_by_username(username)
  staff = Staff.find_by_first_name(username) unless staff
  staff.should_not be_nil
  role = Role.find_or_create_by_name(role)
  staff.staff_roles.build(:role => role)
  staff = set_additional_info(staff, username)
  staff.save!
end

Given /^staff member (\S+) has no roles$/ do |username|
  staff = Staff.find_by_username(username)
  staff = Staff.find_by_first_name(username) unless staff
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

def valid_staff(username, name_flag = nil)
  if name_flag
    staff = Factory(:valid_staff, :first_name => "fname_" + username, :last_name => "lname_" + username, :study_center => 1234)
  else
    staff = Factory(:valid_staff, :first_name => username, :last_name => username, :study_center => 1234)
  end
  staff.staff_roles.build(:role => Role.find_or_create_by_name(Role::ADMINISTRATIVE_STAFF))
  staff.username = username
  staff.email = "#{username}@test.com" 
  staff.save!
  staff
end

def set_additional_info(staff, username)
  staff.username = username unless staff.username
  staff.email = "#{username}@test.com" unless staff.email
  staff
end
