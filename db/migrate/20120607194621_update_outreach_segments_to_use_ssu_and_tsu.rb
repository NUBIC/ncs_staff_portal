class UpdateOutreachSegmentsToUseSsuAndTsu < ActiveRecord::Migration
  def self.up
    add_column :outreach_segments, :ncs_ssu_id, :integer, :references => "ncs_ssus"
    add_column :outreach_segments, :ncs_tsu_id, :integer, :references => "ncs_tsus"
  end

  def self.down
    remove_column(:outreach_segments, :ncs_ssu_id)
    remove_column(:outreach_segments, :ncs_tsu_id)
  end
end
