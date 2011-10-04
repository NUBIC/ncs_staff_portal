require 'ncs_navigator/configuration'

module InitialUserLoader 
  class << self
    def create
      username = NcsNavigator.configuration.staff_portal['username']
      raise "Please provide the initial username." unless username
      user = Staff.find_by_username(username) 
      role = Role.find_by_name(Role::USER_ADMINISTRATOR)
  
      if user 
        if !user.has_role(Role::USER_ADMINISTRATOR)
          user.roles << role
        end
      else
        user = Staff.create!(:username => username, :validate_create => "false")
        user.roles << role
      end
      user
    end
  end
end

InitialUserLoader.create if Role.find_by_name(Role::USER_ADMINISTRATOR)

