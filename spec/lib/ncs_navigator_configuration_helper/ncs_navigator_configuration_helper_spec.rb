require 'spec_helper'

describe NcsNavigatorConfigurationHelper do
  describe "email_reminder" do
    it 'returns false if no email_reminder in configuration file' do
      NcsNavigatorConfigurationHelper.email_reminder.should == false
    end
    
    it 'returns false if email_reminder is setup to false in configuration file' do
      NcsNavigator.configuration = 
        NcsNavigator::Configuration.new(File.expand_path('../navigator_email_reminder_false.ini', __FILE__))
      NcsNavigatorConfigurationHelper.email_reminder.should == false
    end
    
    it 'returns true if email_reminder is setup to true in configuration file' do
      NcsNavigator.configuration = 
        NcsNavigator::Configuration.new(File.expand_path('../navigator_email_reminder_true.ini', __FILE__))
      NcsNavigatorConfigurationHelper.email_reminder.should == true
    end
  end
end