class StaffWeeklyExpense < ActiveRecord::Base
  validates_presence_of :week_start_date
  has_many :management_tasks, :dependent => :destroy
  has_many :data_collection_tasks, :dependent => :destroy
  belongs_to :staff
  
  def self.visible_expenses(staff_ids = [])
    if staff_ids.any? 
      where('staff_id IN (?)', staff_ids)
    else 
      StaffWeeklyExpense.all
    end
  end
end
