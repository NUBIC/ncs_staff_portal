class RemoveNcsAreaIdFromOutreachSegments < ActiveRecord::Migration
  def self.up
    remove_column(:outreach_segments, :ncs_area_id)
  end

  def self.down
    add_column :outreach_segments, :ncs_area_id, :integer
  end
end
