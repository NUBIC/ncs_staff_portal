require 'ncs_navigator/staff_portal'

module NcsNavigator::StaffPortal::Warehouse
  module XmlPassthrough
    def initialize(wh_config)
      @wh_config = wh_config
    end

    def import
      unless path.parent.exist?
        path.parent.mkpath
        Rails.logger.
          warn "Had to create #{path.parent}. Passthrough files will be lost after next deploy."
      end
      create_emitter.emit_xml
    end

    def create_emitter
      @emitter ||= NcsNavigator::Warehouse::XmlEmitter.new(
        @wh_config, path,
        :zip => false, :'include-pii' => true, :tables => passthrough_tables)
    end

    def path
      @path ||= Rails.root + "importer_passthrough/#{filename}-#{timestamp}.xml"
    end

    protected

    def timestamp
      Time.now.getutc.iso8601.gsub(/[^\d]/, '')
    end
  end
end
