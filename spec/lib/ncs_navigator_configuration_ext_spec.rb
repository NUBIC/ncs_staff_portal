require 'spec_helper'
require 'ncs_navigator_configuration_ext'

describe NcsNavigatorConfigurationExt do
  describe "staff_portal_email_reminder" do
    before(:each) do
      @email_reminder = NcsNavigator.configuration.staff_portal['email_reminder']
    end

    after(:each) do
      NcsNavigator.configuration.staff_portal['email_reminder'] = @email_reminder
    end

    it 'returns false if no email_reminder in configuration file' do
      NcsNavigator.configuration.staff_portal_email_reminder?.should == false
    end

    it 'returns false if email_reminder is setup to false in configuration file' do
      NcsNavigator.configuration.staff_portal['email_reminder'] = 'false'
      NcsNavigator.configuration.staff_portal_email_reminder?.should == false
    end

    it 'returns true if email_reminder is setup to true in configuration file' do
      NcsNavigator.configuration.staff_portal['email_reminder'] = 'true'
      NcsNavigator.configuration.staff_portal_email_reminder?.should == true
    end
  end
end
