require 'ncs_navigator/mdes'
require 'ncs_navigator/configuration'

module StaffPortal
  class << self

    def configuration
      @configuration ||= NcsNavigator.configuration
    end

    def psu_id
      configuration.psus.first.id unless NcsNavigator.configuration.psus.blank?
    end

    def psu_name
      @psu_name = mdes_label('psu_cl1', psu_id)
    end

    def footer_logo_left_path
      "config/" << configuration.footer_logo_left.to_s.split("/").last if configuration.footer_logo_left
    end

    def footer_logo_right_path
      "config/" << configuration.footer_logo_right.to_s.split("/").last if configuration.footer_logo_right
    end

    def development_email
       configuration.staff_portal['development_email']
    end

    def week_start_day
      configuration.staff_portal['week_start_day']=~ /monday/ ? "monday" : "sunday"
    end

    ##
    # @return [NcsNavigator::Mdes::Specification] the specification
    # for the MDES version that StaffPortal currently corresponds to.
    def mdes
      mdes_version.specification
    end

    def mdes_version
      @mdes_version ||= MdesVersion.new
    end

    def mdes_version=(version)
      @mdes_version =
        case version
        when MdesVersion
          version
        else
          MdesVersion.new(version.to_s)
        end
    end

    private

    def mdes_label(list_name, id)
      mdes.types.find { |t| t.name == list_name }.code_list.find { |list| list.value == id}.label
    end

  end
end
