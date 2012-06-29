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

  def import_wh_config
    task('import:warehouse_setup').config
  end

  # For import scenarios where the staff data will not go into SP, but
  # rather will exist separately and be ETL'd in parallel.
  desc 'Pass outside staff & outreach data through to an XML file'
  task :passthrough => [:warehouse_setup, :environment] do
    require 'ncs_navigator/staff_portal'

    pass = NcsNavigator::StaffPortal::Warehouse::NotImportedPassthrough.new(import_wh_config)
    pass.import
  end
  
  # Import all the staff, expense and outreach operation data to NCS Navigator Ops.
  desc 'Import operational data'
  task :operational => [:warehouse_setup, :environment] do
    require 'ncs_navigator/staff_portal'
    importer = NcsNavigator::StaffPortal::Warehouse::Importer.new(import_wh_config)

    tables = case
             when ENV['TABLES']
               ENV['TABLES'].split(',').collect(&:to_sym)
             when ENV['START_WITH']
               start = ENV['START_WITH'].to_sym
               all_tables = importer.automatic_producers.collect(&:name)
               start_i = all_tables.index(start)
               unless start_i
                 fail "Can't start from Unknown table #{start}"
               end
             else
               []
             end

    puts "Importing only #{tables.join(', ')}." unless tables.empty?

    importer.import(*tables)
  end
end
