# == Schema Information
#
# Table name: roles
#
#  id   :integer         not null, primary key
#  name :string(255)     not null
#

class Role < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true
  
  SYSTEM_ADMINISTRATOR = "System Administrator"
  USER_ADMINISTRATOR = "User Administrator"
  STAFF_SUPERVISOR = "Staff Supervisor"
  FIELD_STAFF = "Field Staff"
  PHONE_STAFF = "Phone Staff"
  OUTREACH_STAFF = "Outreach Staff"
  BIOLOGICAL_SPECIMEN_COLLECTOR = "Biological Specimen Collector"
  SPECIMEN_PROCESSOR = "Specimen Processor"
  DATA_MANAGER = "Data Manager"
  ADMINISTRATIVE_STAFF = "Administrative Staff"
  
  def self.data_collection_group
    [FIELD_STAFF, PHONE_STAFF, BIOLOGICAL_SPECIMEN_COLLECTOR, SPECIMEN_PROCESSOR ]
  end
  
  def self.management_group
    [SYSTEM_ADMINISTRATOR, USER_ADMINISTRATOR, STAFF_SUPERVISOR, OUTREACH_STAFF, ADMINISTRATIVE_STAFF]
  end
end
