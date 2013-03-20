require 'ncs_navigator/staff_portal'

module NcsNavigator::StaffPortal::Warehouse
  ##
  # An adapter module which exposes the same class-level interface
  # as any MDES-version-specific Enumerator.
  module Enumerator
    class << self
      def select_implementation(warehouse_configuration)
        module_name = warehouse_configuration.models_module.to_s.split('::').last

        begin
          mod = NcsNavigator::StaffPortal::Warehouse.const_get(module_name)
          mod.const_get(:Enumerator)
        rescue NameError => e
          fail "Ops has no enumerator for MDES #{warehouse_configuration.mdes_version}. (#{e})"
        end
      end

      def create_transformer(warehouse_configuration, options={})
        select_implementation(warehouse_configuration).create_transformer(warehouse_configuration, options)
      end
    end
  end
end
