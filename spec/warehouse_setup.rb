require 'ncs_navigator/warehouse'

module NcsNavigator::StaffPortal::Spec
  module WarehouseSetup
    def wh_config
      @wh_config ||= NcsNavigator::Warehouse::Configuration.new.tap do |config|
        config.log_file = Rails.root + 'log/wh-import_test.log'
        config.set_up_logs
        config.mdes_version = '3.0'
        config.output_level = :quiet
        if bcdatabase_config[:group]
          config.bcdatabase_group = bcdatabase_config[:group]
        end
        config.bcdatabase_entries.merge!(
          # these are deliberately the same since replace_schema only
          # works on the working database, while the importer runs
          # against the reporting database.
          :working   => :ncs_staff_portal_test_mdes_warehouse,
          :reporting => :ncs_staff_portal_test_mdes_warehouse
          )
      end
    end

    def wh_init
      @wh_init ||= NcsNavigator::Warehouse::DatabaseInitializer.new(wh_config)
    end

    def bcdatabase_config
      @bcdatabase_config ||=
        if Rails.env == 'ci'
          { :group => :public_ci_postgresql9 }
        else
          { :name => :ncs_staff_portal_test }
        end
    end

    module_function :wh_config, :wh_init, :bcdatabase_config
  end
end