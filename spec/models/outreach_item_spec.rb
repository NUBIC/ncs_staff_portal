require 'spec_helper'

describe OutreachItem do
  it "should create a new instance given valid attributes" do
    item = Factory(:outreach_item)
    item.should_not be_nil
  end
  
  it { should belong_to(:outreach_event) }
  
  it { should validate_presence_of(:item_name) }
  
  it { should validate_presence_of(:item_quantity) }
end
