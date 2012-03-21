# == Schema Information
#
# Table name: management_tasks
#
#  id                      :integer         not null, primary key
#  staff_weekly_expense_id :integer
#  task_date               :date            not null
#  task_type_code          :integer         not null
#  task_type_other         :string(255)
#  hours                   :decimal(, )
#  expenses                :decimal(, )
#  miles                   :decimal(, )
#  comment                 :text
#  created_at              :datetime
#  updated_at              :datetime
#  staff_exp_mgmt_task_id  :string(36)      not null
#

class ManagementTask < ActiveRecord::Base
  validates_presence_of  :task_type
  validates_date :task_date, :allow_blank => false
  validates :hours, :numericality => {:less_than => 100.00, :greater_than_or_equal_to => 0, :allow_nil => true }
  validates :expenses, :numericality => {:less_than => 99999999.99, :greater_than_or_equal_to => 0, :allow_nil => true }
  validates :miles, :numericality => {:less_than => 999.99, :greater_than_or_equal_to => 0, :allow_nil => true }
  validates_with OtherEntryValidator, :entry => :task_type, :other_entry => :task_type_other

  belongs_to :staff_weekly_expense
  belongs_to :task_type, :conditions => "list_name = 'STUDY_MNGMNT_TSK_TYPE_CL1'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :task_type_code

  acts_as_mdes_record :public_id => :staff_exp_mgmt_task_id

  def formatted_task_date
    task_date.nil? ? nil : task_date.to_s
  end

  def formatted_task_date=(task_date)
    self.task_date = task_date
  end
end
