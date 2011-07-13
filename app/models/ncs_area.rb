class NcsArea < ActiveRecord::Base
  validates_presence_of :name, :psu_id
  validates_uniqueness_of :name, :scope => :psu_id
end
