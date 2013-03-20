# == Schema Information
#
# Table name: miscellaneous_expenses
#
#  id                      :integer          not null, primary key
#  staff_weekly_expense_id :integer
#  expense_date            :date
#  expenses                :decimal(10, 2)
#  miles                   :decimal(5, 2)
#  staff_misc_exp_id       :string(36)       not null
#  comment                 :text
#  created_at              :datetime
#  updated_at              :datetime
#  hours                   :decimal(10, 2)
#

class MiscellaneousExpense < ActiveRecord::Base
  strip_attributes
  validates_date :expense_date, :allow_blank => false
  validates :hours, :numericality => {:less_than => 100.00, :greater_than_or_equal_to => 0, :allow_nil => true }
  validates :expenses, :numericality => {:less_than => 99999999.99, :greater_than_or_equal_to => 0, :allow_nil => true }
  validates :miles, :numericality => {:less_than => 999.99, :greater_than_or_equal_to => 0,:allow_nil => true }

  belongs_to :staff_weekly_expense
  acts_as_mdes_record :public_id => :staff_misc_exp_id

  def formatted_expense_date
    expense_date.nil? ? nil : expense_date.to_s
  end

  def formatted_expense_date=(expense_date)
    self.expense_date = expense_date
  end
end
