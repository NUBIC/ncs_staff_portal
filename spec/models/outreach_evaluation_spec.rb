# == Schema Information
#
# Table name: outreach_evaluations
#
#  id                     :integer         not null, primary key
#  outreach_event_id      :integer
#  evaluation_code        :integer         not null
#  evaluation_other       :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  outreach_event_eval_id :string(36)      not null
#  source_id              :string(36)
#

require 'spec_helper'

describe OutreachEvaluation do
  let(:evaluation) { Factory(:outreach_evaluation) }

  it "should create a new instance given valid attributes" do
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

  it 'can access its parent' do
    oe = Factory(:outreach_event)
    oe.outreach_evaluations << evaluation
    oe.save!

    OutreachEvaluation.find(evaluation.id).outreach_event.should == oe
  end
end
