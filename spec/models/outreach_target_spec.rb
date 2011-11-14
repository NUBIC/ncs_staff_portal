# == Schema Information
#
# Table name: outreach_targets
#
#  id                :integer         not null, primary key
#  outreach_event_id :integer
#  target_code       :integer         not null
#  target_other      :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

require 'spec_helper'

describe OutreachTarget do
  it "should create a new instance given valid attributes" do
    target = Factory(:outreach_target)
    target.should_not be_nil
  end
  
  it { should belong_to(:target) }
  
  it { should validate_presence_of(:target) }
  
  describe "validates target_other" do
    let(:target_code) { Factory(:ncs_code, :list_name => "OUTREACH_TARGET_CL1", :display_text => "Other", :local_code => -5) }
    
    it "should not valid if outreach target is 'Other' and target_other value is nil" do
      outreach_target = FactoryGirl.build(:outreach_target, :target => target_code)
      outreach_target.target_other = nil
      outreach_target.should_not be_valid
      outreach_target.should have(1).error_on(:target_other)
    end
    
    it "should not valid if outreach target is 'Other' and target_other value is blank string" do
      outreach_target = FactoryGirl.build(:outreach_target, :target => target_code)
      outreach_target.target_other = ''
      outreach_target.should_not be_valid
      outreach_target.should have(1).error_on(:target_other)
    end
    
    it "should be valid if outreach target is 'Building manager' and target_other value is blank string" do
      outreach_target = FactoryGirl.build(:outreach_target)
      outreach_target.target_other = ''
      outreach_target.should be_valid
      outreach_target.target_other.should == nil
    end
  end
end
