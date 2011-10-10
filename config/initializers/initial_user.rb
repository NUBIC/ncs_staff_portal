require 'ncs_navigator/configuration'

module InitialUserLoader
  class << self
    def create
      username = NcsNavigator.configuration.staff_portal['bootstrap_user']
      raise "Please specify a bootstrap user (see README)." unless username
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

begin
  InitialUserLoader.create if Role.find_by_name(Role::USER_ADMINISTRATOR)
rescue => e
  $stderr.puts "InitialUserLoader.create failed: #{e.class} #{e}"
end
