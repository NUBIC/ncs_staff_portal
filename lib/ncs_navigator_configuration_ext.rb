require 'ncs_navigator/configuration'

module NcsNavigatorConfigurationExt
  def staff_portal_email_reminder?
    NcsNavigator.configuration.staff_portal['email_reminder'] =~ /true/ ? true : false
  end
end

NcsNavigator::Configuration.send(:include, NcsNavigatorConfigurationExt)