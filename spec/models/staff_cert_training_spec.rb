require 'spec_helper'

describe StaffCertTraining do
  it "should create a new instance given valid attributes" do
    training = Factory(:staff_cert_training)
    training.should_not be_nil
  end
  
  it { should validate_presence_of(:certificate_type) }
  
  it { should belong_to(:staff) }
end
