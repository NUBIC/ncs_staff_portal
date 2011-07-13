require 'spec_helper'

describe OutreachRace do
  it "should create a new instance given valid attributes" do
    race = Factory(:outreach_race)
    race.should_not be_nil
  end
  
  it { should belong_to(:race) }
  
  it { should belong_to(:outreach_event) }
  
  it { should validate_presence_of(:race) }
end
