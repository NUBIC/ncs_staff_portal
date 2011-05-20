class CreateOutreachEvaluations < ActiveRecord::Migration
  def self.up
    create_table :outreach_evaluations do |t|
      t.references :outreach_event
      t.integer :evaluation_code
      t.string :evaluation_other

      t.timestamps
    end
  end

  def self.down
    drop_table :outreach_evaluations
  end
end
