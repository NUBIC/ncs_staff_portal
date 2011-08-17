class AddCreatedByToOutreachEvent < ActiveRecord::Migration
  def self.up
    add_column(:outreach_events, :created_by, :integer)
    execute "ALTER TABLE outreach_events ADD CONSTRAINT fk_outreach_events_created_by FOREIGN KEY (created_by) REFERENCES staff(id)"
  end

  def self.down
    execute "ALTER TABLE outreach_events DROP CONSTRAINT fk_outreach_events_created_by"
    remove_column(:outreach_events, :created_by)
  end
end
