class CreateNcsAreas < ActiveRecord::Migration
  def self.up
    create_table :ncs_areas do |t|
      t.string :psu_id
      t.string :name
    end
  end

  def self.down
    drop_table :ncs_areas
  end
end
