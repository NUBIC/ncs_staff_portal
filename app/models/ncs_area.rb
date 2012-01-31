# == Schema Information
#
# Table name: ncs_areas
#
#  id     :integer         not null, primary key
#  psu_id :string(255)     not null
#  name   :string(255)     not null
#

class NcsArea < ActiveRecord::Base
  validates_presence_of :name, :psu_id
  validates_uniqueness_of :name, :scope => :psu_id
  has_many :ncs_area_ssus, :dependent => :destroy
end
