# == Schema Information
#
# Table name: ncs_tsus
#
#  id         :integer         not null, primary key
#  psu_id     :string(36)      not null
#  tsu_id     :string(36)      not null
#  tsu_name   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class NcsTsu < ActiveRecord::Base
end
