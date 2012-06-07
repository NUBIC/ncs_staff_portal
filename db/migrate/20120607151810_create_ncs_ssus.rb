class CreateNcsSsus < ActiveRecord::Migration
  def self.up
    create_table :ncs_ssus do |t|
      t.string :psu_id, :limit => 36, :null => false
      t.string :ssu_id, :limit => 36, :null => false
      t.string :ssu_name

      t.timestamps
    end
    Rake::Task['psu:load_ncs_ssus'].invoke
  end

  def self.down
    drop_table :ncs_ssus
  end
end
