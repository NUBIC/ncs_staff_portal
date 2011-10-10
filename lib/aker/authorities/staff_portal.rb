require 'aker'

module Aker::Authorities
  class StaffPortal

    def initialize()
      @groups = build_groups
      @portal = "NCSNavigator".to_sym
    end

    def amplify!(user)
      base = user(user.username)
      return user unless base
      user.merge!(base)
    end

    def user(username)
      u = Aker::User.new(username)
      staff = Staff.find_by_username(username)
      u.portals << @portal

      if staff
        attributes = ["first_name", "last_name", "email"]
        attributes.each do |a|
          setter = "#{a}="
          if u.respond_to?(setter)
            u.send(setter, staff[a])
          end
        end
        u.group_memberships(@portal).concat(load_group_memberships(staff.roles))
      end
      u
    end

    private

    def build_groups
      begin
        Role.all.collect do |role|
          Aker::Group.new(role.name)
        end
      rescue => e
        $stderr.puts "Loading roles failed. Authorization probably won't work. #{e.class}: #{e}."
        []
      end
    end

    def load_group_memberships(roles)
      gms = []
      roles.each do |role|
       gm = Aker::GroupMembership.new(find_group(role.name))
       gms << gm
      end
      gms
    end

    def find_group(group_name)
      existing = @groups.find_all { |g| g.name == group_name}.compact.first
    end
  end
end
