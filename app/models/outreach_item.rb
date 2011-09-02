class OutreachItem < ActiveRecord::Base
  belongs_to :outreach_event
  validates_presence_of :item_name, :item_quantity
  validate :other_item_check
  
  def other_item_check
    if !item_name.blank? && item_name.match(/\bother\b/i)
      if item_other.blank?
         errors.add :item_other, "can't be blank. Please enter any other item."
      end
    elsif item_other.blank?
       self.item_other = nil
    end
  end
end
