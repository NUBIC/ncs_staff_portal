class CreateOutreachSsus < ActiveRecord::Migration
  def self.up
    create_table :outreach_ssus do |t|
      t.references :outreach_event
      t.string :ssu_code
      t.timestamps
    end
  end

  def self.down
    drop_table :outreach_ssus
  end
end
