# == Schema Information
#
# Table name: outreach_languages
#
#  id                :integer          not null, primary key
#  outreach_event_id :integer
#  language_code     :integer          not null
#  language_other    :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  outreach_lang2_id :string(36)       not null
#  source_id         :string(36)
#

require 'spec_helper'

describe OutreachLanguage do
  it "should create a new instance given valid attributes" do
    language = Factory(:outreach_language)
    language.should_not be_nil
  end

  it { should belong_to(:language) }

  it { should belong_to(:outreach_event) }

  it { should validate_presence_of(:language) }

  describe "validates language_other" do
    let(:language_code) { Factory(:ncs_code, :list_name => "LANGUAGE_CL2", :display_text => "Other", :local_code => -5) }

    it "should not valid if outreach language is 'Other' and language_other value is nil" do
      language = FactoryGirl.build(:outreach_language, :language => language_code)
      language.language_other = nil
      language.should_not be_valid
      language.should have(1).error_on(:language_other)
    end

    it "should not valid if outreach language is 'Other' and language_other value is blank string" do
      language = FactoryGirl.build(:outreach_language, :language => language_code)
      language.language_other = ''
      language.should_not be_valid
      language.should have(1).error_on(:language_other)
    end

    it "should be valid if outreach language is 'English' and language_other value is blank string" do
      language = FactoryGirl.build(:outreach_language)
      language.language_other = ''
      language.should be_valid
      language.language_other.should == nil
    end
  end
end
