class NcsAreaSsu < ActiveRecord::Base
  belongs_to :ncs_area
  validates_presence_of :ncs_area_id, :ssu_id
  validates_uniqueness_of :ssu_id, :scope => :ncs_area_id
end
