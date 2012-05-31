class CreateNcsTsus < ActiveRecord::Migration
  def self.up
    create_table :ncs_tsus do |t|
      t.string :psu_id, :limit => 36, :null => false
      t.string :tsu_id, :limit => 36, :null => false
      t.string :tsu_name

      t.timestamps
    end
  end

  def self.down
    drop_table :ncs_tsus
  end
end
