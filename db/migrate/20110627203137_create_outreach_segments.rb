class CreateOutreachSegments < ActiveRecord::Migration
  def self.up
    create_table :outreach_segments do |t|
      t.references :outreach_event
      t.references :ncs_area
      t.timestamps
    end
  end

  def self.down
    drop_table :outreach_segments
  end
end
