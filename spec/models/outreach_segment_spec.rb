require 'spec_helper'

describe OutreachSegment do
  it "should create a new instance given valid attributes" do
    segment = Factory(:outreach_segment)
    segment.should_not be_nil
  end
  
  it { should belong_to(:ncs_area) }
  
  it { should validate_presence_of(:ncs_area) }
end
