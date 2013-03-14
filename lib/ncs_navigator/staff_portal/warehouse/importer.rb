require 'ncs_navigator/staff_portal/warehouse'
require 'forwardable'

module NcsNavigator::StaffPortal::Warehouse
  ##
  # An adapter module which exposes the same class-level interface
  # as any MDES-version-specific Importer.
  module Importer
    class << self
      def select_implementation(warehouse_configuration)
        module_name = warehouse_configuration.models_module.to_s.split('::').last

        begin
          mod = NcsNavigator::StaffPortal::Warehouse.const_get(module_name)
          mod.const_get(:Importer)
        rescue NameError => e
          fail "Ops has no importer for MDES #{warehouse_configuration.mdes_version}. (#{e})"
        end
      end
    end
  end
end