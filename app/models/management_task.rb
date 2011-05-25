class ManagementTask < ActiveRecord::Base
  validates_presence_of :task_type_code
  belongs_to :staff_weekly_expense
  belongs_to :task_type, :conditions => "list_name = 'STUDY_MNGMNT_TSK_TYPE_CL1'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :task_type_code
end
