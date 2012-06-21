require 'ncs_navigator/configuration'

module InitialUserLoader
  class << self
    def create
      username = NcsNavigator.configuration.staff_portal['bootstrap_user']
      raise "Please specify a bootstrap user (see README)." unless username
      user = Staff.find_by_username(username)
      user_admin_role = Role.find_by_name(Role::USER_ADMINISTRATOR)
      sys_admin_role = Role.find_by_name(Role::SYSTEM_ADMINISTRATOR)

      if user
        user.roles << user_admin_role unless user.has_role(Role::USER_ADMINISTRATOR)
        user.roles << sys_admin_role unless user.has_role(Role::SYSTEM_ADMINISTRATOR)
      else
        user = Staff.create!(:username => username, :validate_create => "false")
        user.roles << user_admin_role
        user.roles << sys_admin_role
      end
      user
    end
  end
end

begin
  InitialUserLoader.create if !%w(ci test).include?(Rails.env) && Role.find_by_name(Role::USER_ADMINISTRATOR) && Role.find_by_name(Role::SYSTEM_ADMINISTRATOR)
rescue => e
  $stderr.puts "InitialUserLoader.create failed: #{e.class} #{e}"
end
