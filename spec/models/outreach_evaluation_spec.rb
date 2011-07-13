require 'spec_helper'

describe OutreachEvaluation do
  it "should create a new instance given valid attributes" do
    evaluation = Factory(:outreach_evaluation)
    evaluation.should_not be_nil
  end
  
  it { should belong_to(:evaluation) }
  
  it { should validate_presence_of(:evaluation) }
end
