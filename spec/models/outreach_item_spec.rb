require 'spec_helper'

describe OutreachItem do
  it "should create a new instance given valid attributes" do
    item = Factory(:outreach_item)
    item.should_not be_nil
  end
  
  it { should belong_to(:outreach_event) }
  
  it { should validate_presence_of(:item_name) }
  
  it { should validate_presence_of(:item_quantity) }
  
  describe "validate item_other" do
    # let(:item_code) { Factory(:ncs_code, :list_name => "OUTREACH_TARGET_CL1", :display_text => "Other", :local_code => -5) }
    
    it "should not valid if outreach item is 'Other' and item_other value is nil" do
      outreach_item = FactoryGirl.build(:outreach_item, :item_name => "Other")
      outreach_item.item_other = nil
      outreach_item.should_not be_valid
      outreach_item.should have(1).error_on(:item_other)
    end
    
    it "should not valid if outreach item is 'Other' and item_other value is blank string" do
      outreach_item = FactoryGirl.build(:outreach_item, :item_name => "Other")
      outreach_item.item_other = ''
      outreach_item.should_not be_valid
      outreach_item.should have(1).error_on(:item_other)
    end
    
    it "should be valid if outreach item is 'Bag' and item_other value is blank string" do
      outreach_item = FactoryGirl.build(:outreach_item)
      outreach_item.item_other = ''
      outreach_item.should be_valid
      outreach_item.item_other.should == nil
    end
  end
end
