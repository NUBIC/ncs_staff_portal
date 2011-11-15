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
#

require 'spec_helper'

describe StaffCertTraining do
  it "should create a new instance given valid attributes" do
    training = Factory(:staff_cert_training)
    training.should_not be_nil
  end

  it { should validate_presence_of(:certificate_type) }

  it { should belong_to(:staff) }

  it "should be validate the cert_date value as '97/97/9777' as 'Not Applicable'" do
    training = FactoryGirl.build(:staff_cert_training)
    training.cert_date = '97/97/9777'
    training.should be_valid
  end

  it "should be validate the cert_date value as '96/96/9666' as 'Unknown'" do
    training = FactoryGirl.build(:staff_cert_training)
    training.cert_date = '96/96/9666'
    training.should be_valid
  end

  it "should be validate the cert_date value for valid date" do
    training = FactoryGirl.build(:staff_cert_training)
    training.cert_date = Date.today
    training.should be_valid
  end

  it "should not validate the cert_date for invalid value" do
    training = FactoryGirl.build(:staff_cert_training)
    training.cert_date = "121211"
    training.should_not be_valid
    training.should have(1).error_on(:cert_date)
  end
end
