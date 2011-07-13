require 'spec_helper'

describe OutreachTarget do
  it "should create a new instance given valid attributes" do
    target = Factory(:outreach_target)
    target.should_not be_nil
  end
  
  it { should belong_to(:target) }
  
  it { should validate_presence_of(:target) }
end
