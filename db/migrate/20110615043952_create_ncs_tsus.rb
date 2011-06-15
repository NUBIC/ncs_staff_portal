class CreateNcsTsus < ActiveRecord::Migration
  def self.up
    create_table :ncs_tsus do |t|
      t.integer :psu_id
      t.string :tsu_id
      t.string :tsu_name
      t.string :area

      t.timestamps
    end
  end

  def self.down
    drop_table :ncs_tsus
  end
end
