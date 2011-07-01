class CreateOutreachLanguages < ActiveRecord::Migration
  def self.up
    create_table :outreach_languages do |t|
      t.references :outreach_event
      t.integer :language_code
      t.string :language_other
      t.timestamps
    end
  end

  def self.down
    drop_table :outreach_languages
  end
end
