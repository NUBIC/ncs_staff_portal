# == Schema Information
#
# Table name: ncs_area_ssus
#
#  id          :integer         not null, primary key
#  ncs_area_id :integer
#  ncs_ssu_id  :integer
#

class NcsAreaSsu < ActiveRecord::Base
  belongs_to :ncs_area
  belongs_to :ncs_ssu
  validates_presence_of :ncs_area_id, :ncs_ssu_id
end
