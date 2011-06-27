class NcsArea < ActiveRecord::Base
  validates_uniqueness_of :name, :scope => :psu_id
end
