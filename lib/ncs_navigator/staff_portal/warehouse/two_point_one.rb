require 'ncs_navigator/staff_portal'
module NcsNavigator::StaffPortal::Warehouse
  module TwoPointOne
    autoload :Enumerator, 'ncs_navigator/staff_portal/warehouse/two_point_one/enumerator'
    autoload :Importer, 'ncs_navigator/staff_portal/warehouse/two_point_one/importer'
  end
end