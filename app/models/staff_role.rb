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

class StaffRole < ActiveRecord::Base
  belongs_to :staff
  belongs_to :role
end
