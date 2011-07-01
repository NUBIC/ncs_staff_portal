class AddNotNullToOutreachFields < ActiveRecord::Migration
  def self.up
    change_column(:outreach_events, :mode_code, :integer, :null => false)
    change_column(:outreach_events, :outreach_type_code, :integer, :null => false)
    change_column(:outreach_events, :tailored_code, :integer, :null => false)
    change_column(:outreach_events, :evaluation_result_code, :integer, :null => false)
  end

  def self.down
    change_column(:outreach_events, :mode_code, :integer, :null => true)
    change_column(:outreach_events, :outreach_type_code, :integer, :null => true)
    change_column(:outreach_events, :tailored_code, :integer, :null => true)
    change_column(:outreach_events, :evaluation_result_code, :integer, :null => true)
  end
end
