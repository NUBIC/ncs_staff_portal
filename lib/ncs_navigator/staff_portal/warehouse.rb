require 'ncs_navigator/staff_portal'

require 'ncs_navigator/warehouse'

module NcsNavigator::StaffPortal
  module Warehouse
    autoload :Enumerator,  'ncs_navigator/staff_portal/warehouse/enumerator'
    autoload :NotImportedPassthrough,
      'ncs_navigator/staff_portal/warehouse/not_imported_passthrough'
    autoload :Passthrough, 'ncs_navigator/staff_portal/warehouse/passthrough'
  end
end
