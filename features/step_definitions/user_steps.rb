Given /^I have users with username (.+)$/ do |usernames|
  usernames.split(', ').each do |username|
    Staff.create!(:username => username, :email => "#{username}@test.com", :first_name => username, :last_name => username, :study_center => 1234)
  end
end