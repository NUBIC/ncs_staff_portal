require 'ncs_navigator/staff_portal'

module NcsNavigator::StaffPortal
  module Mdes
    autoload :VersionMigrator,   		'ncs_navigator/staff_portal/mdes/version_migrator'
    autoload :VersionMigrations, 		'ncs_navigator/staff_portal/mdes/version_migrations'
  end
end