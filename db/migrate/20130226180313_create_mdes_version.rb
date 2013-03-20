class CreateMdesVersion < ActiveRecord::Migration
  def self.up
    create_table :mdes_version, :id => false do |t|
      t.string :number, :limit => 10, :null => false
    end
  end

  def self.down
    drop_table :mdes_version
  end
end