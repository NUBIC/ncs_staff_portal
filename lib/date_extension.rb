class Date
  def beginning_of_week
    if StaffPortal.week_start_day == "monday"
  	  days_to_monday = wday!=0 ? wday-1 : 6
  	  (self - days_to_monday).midnight
  	else
  	  (self - self.wday.days).midnight
  	end
  end
end
