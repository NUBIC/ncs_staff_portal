class CreateStaffLanguages < ActiveRecord::Migration
  def self.up
    create_table :staff_languages do |t|
      t.references :staff
      t.integer :lang_code
      t.string :lang_other
      t.timestamps
    end
  end

  def self.down
    drop_table :staff_languages
  end
end
