require 'spec_helper'

describe OutreachEvent do
  it "should create a new instance given valid attributes" do
    event = Factory(:outreach_event)
    event.should_not be_nil
  end
  
  it { should validate_presence_of(:name) }
  
  it { should validate_presence_of(:mode) }
  
  it { should validate_presence_of(:outreach_type) }
    
  it { should validate_presence_of(:tailored) }
      
  it { should validate_presence_of(:evaluation_result) }
  
end
