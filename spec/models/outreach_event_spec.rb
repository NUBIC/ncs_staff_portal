require 'spec_helper'

describe OutreachEvent do
  it "should create a new instance given valid attributes" do
    event = Factory.create(:outreach_event)
    event.should_not be_nil
  end
  
  it { should have_many(:outreach_segments) }
  
  it { should have_many(:outreach_staff_members) }
  
  it { should have_many(:ncs_areas).through(:outreach_segments) }
  
  it { should validate_presence_of(:name) }
  
  it { should validate_presence_of(:mode) }
  
  it { should validate_presence_of(:outreach_type) }
    
  it { should validate_presence_of(:tailored) }
      
  it { should validate_presence_of(:evaluation_result) }
  
  it "should not be valid if outreach event date is after today" do
    event = FactoryGirl.build(:outreach_event, :event_date => Date.today + 2.days)
    event.should_not be_valid
    event.should have(1).error_on(:event_date)
  end
  
  it "should be valid if outreach event date is before today" do
    event = FactoryGirl.build(:outreach_event, :event_date => Date.today - 2.days)
    event.should be_valid
  end
  
  it "should be valid if outreach event date is as today" do
    event = FactoryGirl.build(:outreach_event, :event_date => Date.today)
    event.should be_valid
  end
end
