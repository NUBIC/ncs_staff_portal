# == Schema Information
#
# Table name: staff_weekly_expenses
#
#  id              :integer         not null, primary key
#  staff_id        :integer
#  week_start_date :date            not null
#  rate            :decimal(5, 2)
#  hours           :decimal(5, 2)
#  expenses        :decimal(10, 2)
#  miles           :decimal(5, 2)
#  comment         :text
#  created_at      :datetime
#  updated_at      :datetime
#

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

  def total_hours
    self.management_tasks.map(&:hours).compact.inject(0) { |total, hours| total + hours } +
      self.data_collection_tasks.map(&:hours).compact.inject(0) { |total, hours| total + hours }
  end

  def total_miles
    self.management_tasks.map(&:miles).compact.inject(0) { |total, miles| total + miles} +
      self.data_collection_tasks.map(&:miles).compact.inject(0) { |total, miles| total + miles }
  end

  def total_expenses
    self.management_tasks.map(&:expenses).compact.inject(0) { |total, expenses| total + expenses } +
      self.data_collection_tasks.map(&:expenses).compact.inject(0) { |total, expenses| total + expenses }
  end

  def total_tasks
    self.management_tasks.length + self.data_collection_tasks.length
  end
end
