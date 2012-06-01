# == Schema Information
#
# Table name: outreach_races
#
#  id                :integer         not null, primary key
#  outreach_event_id :integer
#  race_code         :integer         not null
#  race_other        :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  outreach_race_id  :string(36)      not null
#  source_id         :string(36)
#

require 'spec_helper'

describe OutreachRace do
  it "should create a new instance given valid attributes" do
    race = Factory(:outreach_race)
    race.should_not be_nil
  end
  
  it { should belong_to(:race) }
  
  it { should belong_to(:outreach_event) }
  
  it { should validate_presence_of(:race) }
  
  describe "validates race_other" do
    let(:race_code) { Factory(:ncs_code, :list_name => "RACE_CL3", :display_text => "Other", :local_code => -5) }
    
    it "should not valid if outreach race is 'Other' and race_other value is nil" do
      outreach_race = FactoryGirl.build(:outreach_race, :race => race_code)
      outreach_race.race_other = nil
      outreach_race.should_not be_valid
      outreach_race.should have(1).error_on(:race_other)
    end
    
    it "should not valid if outreach race is 'Other' and race_other value is blank string" do
      outreach_race = FactoryGirl.build(:outreach_race, :race => race_code)
      outreach_race.race_other = ''
      outreach_race.should_not be_valid
      outreach_race.should have(1).error_on(:race_other)
    end
    
    it "should be valid if outreach race is 'White' and race_other value is blank string" do
      outreach_race = FactoryGirl.build(:outreach_race)
      outreach_race.race_other = ''
      outreach_race.should be_valid
      outreach_race.race_other.should == nil
    end
  end
end
