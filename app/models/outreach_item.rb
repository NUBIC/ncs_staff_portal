class OutreachItem < ActiveRecord::Base
  belongs_to :outreach_event
  validates_presence_of :item_name, :item_quantity
end
