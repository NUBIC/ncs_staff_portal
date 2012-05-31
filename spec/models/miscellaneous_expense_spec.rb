# == Schema Information
#
# Table name: miscellaneous_expenses
#
#  id                      :integer         not null, primary key
#  staff_weekly_expense_id :integer
#  expense_date            :date
#  expenses                :decimal(10, 2)
#  miles                   :decimal(5, 2)
#  staff_misc_exp_id       :string(36)      not null
#  comment                 :text
#  created_at              :datetime
#  updated_at              :datetime
#

require 'spec_helper'

describe MiscellaneousExpense do
  pending "add some examples to (or delete) #{__FILE__}"
end
