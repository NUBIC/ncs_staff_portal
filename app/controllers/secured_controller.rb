class SecuredController < ApplicationController
  protect_from_forgery
  include Aker::Rails::SecuredController 
  
  before_filter :set_current_staff

  def dashboard
    if permit?(*Role.management_group) 
      redirect_to new_staff_management_task_path(@current_staff.id)
    elsif permit?(*Role.data_collection_group)
      redirect_to new_staff_data_collection_task_path(@current_staff.id)
    else
      redirect_to staff_path(@current_staff)
    end
  end

  def set_current_staff
    @current_staff = Staff.find_by_username(current_user.username)
    unless (@current_staff && @current_staff.is_active) || current_user.username == 'psc_application'
      throw :warden
    end
  end
  
  def check_user_access(requested_staff)
    if requested_staff
      unless current_user.username == 'psc_application' or requested_staff.id == @current_staff.id or @current_staff.visible_employees.map(&:id).include?(requested_staff.id)
        throw :warden
      end
    end
  end
  
  def same_as_current_user(requested_staff)
    if @current_staff
      requested_staff.id == @current_staff.id ? true : false
    else
      false
    end
  end
end
