require 'spec_helper'

describe OutreachEvaluation do
  it "should create a new instance given valid attributes" do
    evaluation = Factory(:outreach_evaluation)
    evaluation.should_not be_nil
  end
  
  it { should belong_to(:evaluation) }
  
  it { should validate_presence_of(:evaluation) }
  
  describe "validates evaluation_other" do
    let(:evaluation_code) { Factory(:ncs_code, :list_name => "OUTREACH_EVAL_CL1", :display_text => "Other", :local_code => -5) }
    
    it "should not valid if outreach evaluation is 'Other' and evaluation_other value is nil" do
      outreach_evaluation = FactoryGirl.build(:outreach_evaluation, :evaluation => evaluation_code)
      outreach_evaluation.evaluation_other = nil
      outreach_evaluation.should_not be_valid
      outreach_evaluation.should have(1).error_on(:evaluation_other)
    end
    
    it "should not valid if outreach evaluation is 'Other' and evaluation_other value is blank string" do
      outreach_evaluation = FactoryGirl.build(:outreach_evaluation, :evaluation => evaluation_code)
      outreach_evaluation.evaluation_other = ''
      outreach_evaluation.should_not be_valid
      outreach_evaluation.should have(1).error_on(:evaluation_other)
    end
    
    it "should be valid if outreach evaluation is 'Focus groups' and evaluation_other value is blank string" do
      outreach_evaluation = FactoryGirl.build(:outreach_evaluation)
      outreach_evaluation.evaluation_other = ''
      outreach_evaluation.should be_valid
      outreach_evaluation.evaluation_other.should == nil
    end
  end
end
