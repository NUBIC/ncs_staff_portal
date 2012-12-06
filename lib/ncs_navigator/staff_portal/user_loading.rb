require 'ncs_navigator/staff_portal'

module NcsNavigator::StaffPortal
  ##
  # Common patterns for loading user records.
  module UserLoading
    ##
    # Returns either a {MachineAccount} or {Staff} record.  Machine accounts
    # are searched first.
    #
    # id may be either an alphanumeric username or an integer-as-string.  If no
    # results are returned for id-as-username, then it'll be coerced to an
    # integer and lookup retried with the coercion result.
    #
    # Returns a user object or nil.
    def find_user(id)
      find_by_username(id) || find_by_numeric_id(id.to_i)
    end

    ##
    # Finds a {MachineAccount} or {Staff} object by its username.
    #
    # Returns a user object or nil.
    def find_by_username(username)
      MachineAccount.find_by_username(username) || Staff.find_by_username(username)
    end

    ##
    # @private
    def find_by_numeric_id(id)
      MachineAccount.find_by_numeric_id(id) || Staff.find_by_numeric_id(id)
    end
  end
end
