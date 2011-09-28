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
end
