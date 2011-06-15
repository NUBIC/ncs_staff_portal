class CreateNcsSsus < ActiveRecord::Migration
  def self.up
    create_table :ncs_ssus do |t|
      t.integer :psu_id
      t.string :ssu_id
      t.string :ssu_name
      t.string :area

      t.timestamps
    end
  end

  def self.down
    drop_table :ncs_ssus
  end
end
