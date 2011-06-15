class OutreachSsu < ActiveRecord::Base
  belongs_to :outreach_event
  validates_presence_of :ssu_code
  belongs_to :ssu, :class_name => 'NcsSsu', :primary_key => :ssu_id, :foreign_key => :ssu_code
end
