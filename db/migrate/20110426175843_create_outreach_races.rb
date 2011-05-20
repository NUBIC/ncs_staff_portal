class CreateOutreachRaces < ActiveRecord::Migration
  def self.up
    create_table :outreach_races do |t|
      t.references :outreach_event
      t.integer :race_code
      t.string :race_other

      t.timestamps
    end
  end

  def self.down
    drop_table :outreach_races
  end
end
