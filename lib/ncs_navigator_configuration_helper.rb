require 'ncs_navigator/configuration'

module NcsNavigatorConfigurationHelper
  def self.email_reminder
    if NcsNavigator.configuration.staff_portal['email_reminder'] && NcsNavigator.configuration.staff_portal['email_reminder'].match(/^\s*true\s*$/i) 
      true
    else
      false
    end
  end
end