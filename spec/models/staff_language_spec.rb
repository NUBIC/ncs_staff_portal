# == Schema Information
#
# Table name: staff_languages
#
#  id                :integer          not null, primary key
#  staff_id          :integer
#  lang_code         :integer          not null
#  lang_other        :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  staff_language_id :string(36)       not null
#

require 'spec_helper'

describe StaffLanguage do
  it "should create a new instance given valid attributes" do
     language = Factory(:staff_language)
     language.should_not be_nil
  end

  it { should belong_to(:lang) }

  it { should validate_presence_of(:lang) }

  it { should belong_to(:staff) }

  describe '#public_id' do
    it 'is :staff_language_id' do
      StaffLanguage.new(:staff_language_id => 'FTE').public_id.should == 'FTE'
    end
  end

  describe "validates lang_other" do
    let(:lang_code) { Factory(:ncs_code, :list_name => "LANGUAGE_CL2", :display_text => "Other", :local_code => -5) }

    it "should not valid if staff language is 'Other' and language_other value is nil" do
      language = FactoryGirl.build(:staff_language, :lang => lang_code)
      language.lang_other = nil
      language.should_not be_valid
      language.should have(1).error_on(:lang_other)
    end

    it "should not valid if outreach language is 'Other' and language_other value is blank string" do
      language = FactoryGirl.build(:staff_language, :lang => lang_code)
      language.lang_other = ''
      language.should_not be_valid
      language.should have(1).error_on(:lang_other)
    end

    it "should be valid if outreach language is 'English' and language_other value is blank string" do
      language = FactoryGirl.build(:staff_language)
      language.lang_other = ''
      language.should be_valid
      language.lang_other.should == nil
    end
  end

  describe "as_json" do
    it "contains name" do
      language = Factory(:staff_language)
      actual_json = language.as_json
      actual_json["name"].should == "English"
    end
  end
end
