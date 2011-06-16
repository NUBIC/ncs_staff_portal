class AddBirthdateToStaff < ActiveRecord::Migration
  def self.up
    remove_column(:staff, :yob)
    remove_column(:staff, :age_range_code)
    add_column(:staff, :birth_date, :date)
  end

  def self.down
    remove_column(:staff, :birth_date)
    add_column(:staff, :age_range_code, :integer)
    add_column(:staff, :yob, :integer)
  end
end
