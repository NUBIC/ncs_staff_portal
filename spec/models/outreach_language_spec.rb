require 'spec_helper'

describe OutreachLanguage do
  it "should create a new instance given valid attributes" do
    language = Factory(:outreach_language)
    language.should_not be_nil
  end
  
  it { should belong_to(:language) }
  
  it { should belong_to(:outreach_event) }
  
  it { should validate_presence_of(:language) }
end
