class UpdateOutreachQuantityColumn < ActiveRecord::Migration
  def self.up
    remove_column(:outreach_events, :quantity)
    add_column(:outreach_events, :letters_quantity, :integer)
    add_column(:outreach_events, :attendees_quantity, :integer)
  end

  def self.down
    remove_column(:outreach_events, :attendees_quantity)
    remove_column(:outreach_events, :letters_quantity)
    add_column(:outreach_events, :quantity, :integer)
  end
end
