class CreateNcsAreaSsus < ActiveRecord::Migration
  def self.up
    create_table :ncs_area_ssus do |t|
      t.references :ncs_area
      t.string :ssu_id
      t.string :ssu_name
    end
  end

  def self.down
    drop_table :ncs_area_ssus
  end
end
