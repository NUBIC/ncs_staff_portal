class AddNameToOutreachEvent < ActiveRecord::Migration
  def self.up
    add_column(:outreach_events, :name, :string)
  end

  def self.down
    remove_column(:outreach_events, :name)
  end
end
