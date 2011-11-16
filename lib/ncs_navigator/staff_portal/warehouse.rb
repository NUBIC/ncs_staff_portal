require 'ncs_navigator/staff_portal'

require 'ncs_navigator/warehouse'

module NcsNavigator::StaffPortal
  module Warehouse
    autoload :Enumerator, 'ncs_navigator/staff_portal/warehouse/enumerator'
  end
end
