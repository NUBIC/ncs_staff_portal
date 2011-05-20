class CreateOutreachEvents < ActiveRecord::Migration
  def self.up
    create_table :outreach_events do |t|
      t.date :event_date
      t.integer :mode_code
      t.string :mode_other
      t.integer :outreach_type_code
      t.string :outreach_type_other
      t.integer :tailored_code
      t.integer :language_specific_code
      t.integer :language_code
      t.string :language_other
      t.integer :race_specific_code
      t.integer :culture_specific_code
      t.integer :culture_code
      t.string :culture_other
      t.integer :quantity
      t.decimal :cost
      t.integer :no_of_staff
      t.integer :evaluation_result_code

      t.timestamps
    end
  end

  def self.down
    drop_table :outreach_events
  end
end
