class CreateOutreachItems < ActiveRecord::Migration
  def self.up
    create_table :outreach_items do |t|
      t.references :outreach_event
      t.string :item_name
      t.string :item_other
      t.integer :item_quantity
      t.timestamps
    end
  end

  def self.down
    drop_table :outreach_items
  end
end
