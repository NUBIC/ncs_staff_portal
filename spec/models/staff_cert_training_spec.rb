# == Schema Information
#
# Table name: staff_cert_trainings
#
#  id                    :integer         not null, primary key
#  staff_id              :integer
#  certificate_type_code :integer         not null
#  complete_code         :integer         not null
#  cert_date             :string(255)
#  background_check_code :integer         not null
#  frequency             :string(255)
#  expiration_date       :date
#  comment               :text
#  created_at            :datetime
#  updated_at            :datetime
#  staff_cert_list_id    :string(36)      not null
#

require 'spec_helper'

describe StaffCertTraining do
  it "should create a new instance given valid attributes" do
    training = Factory(:staff_cert_training)
    training.should_not be_nil
  end

  it { should validate_presence_of(:certificate_type) }

  it { should belong_to(:staff) }

  describe '#public_id' do
    it 'is :staff_cert_list_id' do
      StaffCertTraining.new(:staff_cert_list_id => 'GH').public_id.should == 'GH'
    end
  end
  
  describe "cert_date" do
    it "should not be blank if complete is 'Yes'" do
      training = FactoryGirl.build(:staff_cert_training, :complete => Factory(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1))
      training.should_not be_valid
      training.should have(1).error_on(:cert_date)
      training.errors[:cert_date].should == ["is not a valid date"]
    end
    
    it "can be blank if complete is 'No'" do
      training = FactoryGirl.build(:staff_cert_training)
      training.should be_valid
      training.should_not have(1).error_on(:cert_date)
    end
    
    it "should be valid if value is as 'Not Applicable'" do
      training = FactoryGirl.build(:staff_cert_training, :cert_date => NcsCode.not_applicable_date)
      training.should be_valid
      training.cert_date.should == NcsCode.not_applicable_date
    end

    it "should be valid if value is as 'Unknown'" do
      training = FactoryGirl.build(:staff_cert_training, :cert_date => NcsCode.unknown_date)
      training.should be_valid
      training.cert_date.should == NcsCode.unknown_date
    end

    it "should be valid for valid date" do
      training = FactoryGirl.build(:staff_cert_training)
      training.cert_date = Date.today
      training.should be_valid
    end

    it "should not be valid invalid value" do
      training = FactoryGirl.build(:staff_cert_training)
      training.cert_date = "121211"
      training.should_not be_valid
      training.should have(1).error_on(:cert_date)
    end
  end
  
  describe "only_date" do
    it "should return true if cert_date is a date" do
      training = FactoryGirl.build(:staff_cert_training, :cert_date => Date.today)
      training.only_date.should == true
    end
    
    it "should return false if cert_date is unknown date" do
      training = FactoryGirl.build(:staff_cert_training, :cert_date => NcsCode.unknown_date)
      training.only_date.should == false
    end
    
    it "should return false if cert_date is not applicable date" do
      training = FactoryGirl.build(:staff_cert_training, :cert_date => NcsCode.not_applicable_date)
      training.only_date.should == false
    end
  end
  
  describe "format_cert_date" do
    it "should not the format the blank value" do
      training = Factory(:staff_cert_training)
      training.cert_date.should be_nil
    end
    
    it "should not the format the not_applicable_date value" do
      training = Factory(:staff_cert_training, :cert_date => NcsCode.not_applicable_date)
      training.cert_date.should == NcsCode.not_applicable_date
    end
    
    it "should not the format the unknown_date value" do
      training = Factory(:staff_cert_training, :cert_date => NcsCode.unknown_date)
      training.cert_date.should == NcsCode.unknown_date
    end
    
    it "should the format only date value" do
      training = Factory(:staff_cert_training, :cert_date => "2011-12-28")
      training.cert_date.should == "2011-12-28"
    end
  end
end
