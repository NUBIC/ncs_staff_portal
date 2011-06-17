class CreateOutreachTsus < ActiveRecord::Migration
  def self.up
    create_table :outreach_tsus do |t|
      t.references :outreach_event
      t.string :tsu_code
      t.timestamps
    end
  end

  def self.down
    drop_table :outreach_tsus
  end
end
