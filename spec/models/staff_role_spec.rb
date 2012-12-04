# == Schema Information
#
# Table name: staff_roles
#
#  id         :integer         not null, primary key
#  staff_id   :integer
#  role_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe StaffRole do
  it "should create a new instance given valid attributes" do
    staff_role = Factory(:staff_role)
    staff_role.should_not be_nil
  end

  it { should belong_to(:staff) }

  it { should belong_to(:role) }
end
