# == Schema Information
#
# Table name: outreach_events
#
#  id                     :integer         not null, primary key
#  event_date             :string(10)
#  mode_code              :integer         not null
#  mode_other             :string(255)
#  outreach_type_code     :integer         not null
#  outreach_type_other    :string(255)
#  tailored_code          :integer         not null
#  language_specific_code :integer
#  race_specific_code     :integer
#  culture_specific_code  :integer
#  culture_code           :integer
#  culture_other          :string(255)
#  cost                   :decimal(, )
#  no_of_staff            :integer
#  evaluation_result_code :integer         not null
#  created_at             :datetime
#  updated_at             :datetime
#  name                   :string(255)
#  letters_quantity       :integer
#  attendees_quantity     :integer
#  created_by             :integer
#  outreach_event_id      :string(36)      not null
#  source_id              :string(36)
#  event_date_date        :date
#

require 'spec_helper'

describe OutreachEvent do
  it "should create a new instance given valid attributes" do
    event = Factory.create(:outreach_event)
    event.should_not be_nil
  end

  it { should have_many(:outreach_segments) }

  it { should have_many(:outreach_staff_members) }

  it { should have_many(:ncs_ssus).through(:outreach_segments) }

  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:mode) }

  it { should validate_presence_of(:outreach_type) }

  it { should validate_presence_of(:tailored) }

  it { should validate_presence_of(:evaluation_result) }

  describe "validates" do
    describe "event_date" do
      it "should be valid if valid date" do
        event = FactoryGirl.build(:outreach_event, :event_date => "2012-12-12")
        event.should be_valid
      end

      it "should be valid for valid for mdes options (9777-96-91)" do
        event = FactoryGirl.build(:outreach_event, :event_date => "9777-96-91")
        event.should be_valid
      end

      it "should be valid for valid date and valid mdes options (9777-12-91)" do
        event = FactoryGirl.build(:outreach_event, :event_date => "9777-12-91")
        event.should be_valid
      end

      it "should not be valid for if date has month which not valid month or not in mdes option" do
        event = FactoryGirl.build(:outreach_event, :event_date => "9777-14-91")
        event.should_not be_valid
        event.should have(1).error_on(:event_date)
        event.errors[:event_date].should == ["9777-14-91 is not the valid mdes format date."]
      end

      it "should not be valid for if date has day which not valid date or not in mdes option" do
        event = FactoryGirl.build(:outreach_event, :event_date => "9777-12-34")
        event.should_not be_valid
        event.should have(1).error_on(:event_date)
        event.errors[:event_date].should == ["9777-12-34 is not the valid mdes format date."]
      end

      it "should not be valid for if date is random string" do
        event = FactoryGirl.build(:outreach_event, :event_date => "abcd")
        event.should_not be_valid
        event.should have(1).error_on(:event_date)
        event.errors[:event_date].should == ["abcd is not the valid mdes format date."]
      end
    end

    describe "culture_other" do
      let(:culture_code) { Factory(:ncs_code, :list_name => "CULTURE_CL1", :display_text => "Other", :local_code => -5) }

      it "should not valid if outreach culture is 'Other' and culture_other value is nil" do
        outreach_event = FactoryGirl.build(:outreach_event, :culture => culture_code)
        outreach_event.culture_other = nil
        outreach_event.should_not be_valid
        outreach_event.should have(1).error_on(:culture_other)
      end

      it "should not valid if outreach culture is 'Other' and culture_other value is blank string" do
        outreach_event = FactoryGirl.build(:outreach_event, :culture => culture_code)
        outreach_event.culture_other = ''
        outreach_event.should_not be_valid
        outreach_event.should have(1).error_on(:culture_other)
      end

      it "should be valid if outreach culture is 'Mexican' and culture_other value is blank string" do
        outreach_event = FactoryGirl.build(:outreach_event, :culture => Factory(:ncs_code, :list_name => "CULTURE_CL1", :display_text => "Mexican", :local_code => 1))
        outreach_event.culture_other = ''
        outreach_event.should be_valid
        outreach_event.culture_other.should == nil
      end
    end
    describe "mode_other" do
      let(:mode_code) { Factory(:ncs_code, :list_name => "OUTREACH_MODE_CL1", :display_text => "Other", :local_code => -5) }

      it "should not valid if outreach mode is 'Other' and mode_other value is nil" do
        outreach_event = FactoryGirl.build(:outreach_event, :mode => mode_code)
        outreach_event.mode_other = nil
        outreach_event.should_not be_valid
        outreach_event.should have(1).error_on(:mode_other)
      end

      it "should not valid if outreach mode is 'Other' and mode_other value is blank string" do
        outreach_event = FactoryGirl.build(:outreach_event, :mode => mode_code)
        outreach_event.mode_other = ''
        outreach_event.should_not be_valid
        outreach_event.should have(1).error_on(:mode_other)
      end

      it "should be valid if outreach mode is 'In-person' and mode_other value is blank string" do
        outreach_event = FactoryGirl.build(:outreach_event)
        outreach_event.mode_other = ''
        outreach_event.should be_valid
        outreach_event.mode_other.should == nil
      end
    end

    describe "outreach_type_other" do
      let(:outreach_type_code) { Factory(:ncs_code, :list_name => "OUTREACH_TYPE_CL1", :display_text => "Other", :local_code => -5) }

      it "should not valid if outreach type is 'Other' and outreach_type_other value is nil" do
        outreach_event = FactoryGirl.build(:outreach_event, :outreach_type => outreach_type_code)
        outreach_event.outreach_type_other = nil
        outreach_event.should_not be_valid
        outreach_event.should have(1).error_on(:outreach_type_other)
      end

      it "should not valid if outreach type is 'Other' and outreach_type_other value is blank string" do
        outreach_event = FactoryGirl.build(:outreach_event, :outreach_type => outreach_type_code)
        outreach_event.outreach_type_other = ''
        outreach_event.should_not be_valid
        outreach_event.should have(1).error_on(:outreach_type_other)
      end

      it "should be valid if outreach type is 'Letters' and outreach_type_other value is blank string" do
        outreach_event = FactoryGirl.build(:outreach_event)
        outreach_event.outreach_type_other = ''
        outreach_event.should be_valid
        outreach_event.outreach_type_other.should == nil
      end
    end
  end
end
