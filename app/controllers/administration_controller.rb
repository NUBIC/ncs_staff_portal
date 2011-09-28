class AdministrationController < SecuredController
  # permit Role::STAFF_SUPERVISOR, Role::SYSTEM_ADMINISTRATOR, Role::USER_ADMINISTRATOR
  
  def index
    set_tab :admin
  end
end
