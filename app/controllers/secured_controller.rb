class SecuredController < ApplicationController
  protect_from_forgery
  include Bcsec::Rails::SecuredController 
  
  before_filter :set_current_staff

  def dashboard
    if current_user.permit?(:supervisor)
      redirect_to staff_weekly_expenses_path
    else
      redirect_to new_staff_management_task_path(@current_staff.id) 
    end
  end

  def set_current_staff
   @current_staff = Staff.find_by_username(current_user.username)
  end
  
  def check_user_access(requested_staff)
    unless permit?(:supervisor) or (requested_staff.id == @current_staff.id)
      throw :warden
    end   
  end
end
