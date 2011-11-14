# == Schema Information
#
# Table name: ncs_area_ssus
#
#  id          :integer         not null, primary key
#  ncs_area_id :integer
#  ssu_id      :string(255)     not null
#  ssu_name    :string(255)
#

class NcsAreaSsu < ActiveRecord::Base
  belongs_to :ncs_area
  validates_presence_of :ncs_area_id, :ssu_id
  validates_uniqueness_of :ssu_id, :scope => :ncs_area_id
end
