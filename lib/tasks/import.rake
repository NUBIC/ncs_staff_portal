namespace :import do
  task :warehouse_setup do |t|
    class << t; attr_accessor :config; end

    source_warehouse_config_file = ENV['IMPORT_CONFIG'] || '/etc/nubic/ncs/warehouse/import.rb'

    require 'ncs_navigator/warehouse'

    t.config = NcsNavigator::Warehouse::Configuration.
      from_file(source_warehouse_config_file)
    t.config.set_up_logs

    NcsNavigator::Warehouse::DatabaseInitializer.new(t.config).set_up_repository
  end

  # For import scenarios where the staff data will not go into SP, but
  # rather will exist separately and be ETL'd in parallel.
  desc 'Pass outside staff & outreach data through to an XML file'
  task :passthrough => [:warehouse_setup, :environment] do
    require 'ncs_navigator/core'

    pass = NcsNavigator::StaffPortal::Warehouse::NotImportedPassthrough.new(import_wh_config)
    pass.import
  end
end
