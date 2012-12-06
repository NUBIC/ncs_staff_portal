class Date
  def beginning_of_week
    if StaffPortal.week_start_day == "monday"
  	  days_to_start_day = wday!=0 ? wday-1 : 6
  	else
  	  days_to_start_day = wday.days
  	end
    (self - days_to_start_day).midnight.strftime('%Y-%m-%d')
  end
end
