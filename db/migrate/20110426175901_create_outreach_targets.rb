class CreateOutreachTargets < ActiveRecord::Migration
  def self.up
    create_table :outreach_targets do |t|
      t.references :outreach_event
      t.integer :target_code
      t.string :target_other

      t.timestamps
    end
  end

  def self.down
    drop_table :outreach_targets
  end
end
