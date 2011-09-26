class AddFirstNameLastNameToStaff < ActiveRecord::Migration
  def self.up
    add_column(:staff, :first_name, :string)
    add_column(:staff, :last_name, :string)
    execute "UPDATE staff SET (first_name, last_name) = (split_part(name, ' ', 1) , split_part(name, ' ', 2))"
    remove_column(:staff, :name)
  end

  def self.down
    add_column(:staff, :name, :string)
    remove_column(:staff, :last_name)
    remove_column(:staff, :first_name)
  end
end
