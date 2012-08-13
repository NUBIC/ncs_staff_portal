class UpdateZipcodeType < ActiveRecord::Migration
  def self.up
  	change_column :staff, :zipcode, :string, :limit => 5
  end

  def self.down
  	change_column :staff, :zipcode, :integer
  end
end
