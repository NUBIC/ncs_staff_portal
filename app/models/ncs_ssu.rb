# == Schema Information
#
# Table name: ncs_ssus
#
#  id         :integer         not null, primary key
#  psu_id     :string(36)      not null
#  ssu_id     :string(36)      not null
#  ssu_name   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class NcsSsu < ActiveRecord::Base
  validates_presence_of :ssu_id, :psu_id
end
