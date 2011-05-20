class SecuredController < ApplicationController
  protect_from_forgery
  include Bcsec::Rails::SecuredController 
  
  before_filter :set_current_staff

  def dashboard
    redirect_to staff_index_path
  end

  def set_current_staff
   @current_staff = Staff.find_by_netid(current_user.username)
  end
end
