# == Schema Information
#
# Table name: roles
#
#  id   :integer         not null, primary key
#  name :string(255)     not null
#

class Role < ActiveRecord::Base
  include Roles

  validates :name, :presence => true, :uniqueness => true

  def self.data_collection_group
    [FIELD_STAFF, PHONE_STAFF, BIOLOGICAL_SPECIMEN_COLLECTOR, SPECIMEN_PROCESSOR ]
  end

  def self.management_group
    [SYSTEM_ADMINISTRATOR, USER_ADMINISTRATOR, STAFF_SUPERVISOR, OUTREACH_STAFF, ADMINISTRATIVE_STAFF]
  end

  def self.create_all
    ALL_ROLES.each do |role|
      Role.find_or_create_by_name(role)
    end
  end
end
