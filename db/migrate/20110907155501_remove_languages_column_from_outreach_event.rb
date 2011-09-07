class RemoveLanguagesColumnFromOutreachEvent < ActiveRecord::Migration
  def self.up
    remove_column(:outreach_events, :language_code)
    remove_column(:outreach_events, :language_other)
  end

  def self.down
    add_column(:outreach_events, :language_code, :integer)
    add_column(:outreach_events, :language_other, :string)
  end
end
