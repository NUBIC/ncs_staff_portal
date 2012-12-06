class UpdateOutreachEventDate < ActiveRecord::Migration
  def self.up
    add_column :outreach_events, :event_date_date, :date
    execute "UPDATE outreach_events SET event_date_date = event_date"
    change_column :outreach_events, :event_date, :string, :limit => 10
  end

  def self.down
    remove_column :outreach_events, :event_date
    add_column :outreach_events, :event_date, :date
    execute "UPDATE outreach_events SET event_date = event_date_date"
    remove_column :outreach_events, :event_date_date
  end
end
