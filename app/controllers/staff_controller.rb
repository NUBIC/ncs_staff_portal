class StaffController < SecuredController
  layout "layouts/application"
  before_filter :check_staff_access,  :only => %w(show edit) 
  
  set_tab :general_info, :vertical
  set_tab :admin, :only => %w(index users new edit_user)

  add_breadcrumb "Admin", :administration_index_path, :only => %w(index users new edit_user) 
  add_breadcrumb "Administer user accounts", :users_path, :only => %w(new users edit_user)
  add_breadcrumb "Manage staff details", :staff_index_path, :only => %w(index)


  # GET /staff
  # GET /staff.xml
  def index
    if permit?(Role::STAFF_SUPERVISOR)
      params[:page] ||= 1
      if params[:first_name] || params[:last_name] || params[:username]
        @staff = @current_staff.visible_employees & Staff.where(construct_condition_string(params))
      else
        @staff = @current_staff.visible_employees
      end
      @staff_list = (@staff.select(&:username).sort_by(&:username) + @staff.reject(&:username)).select { |s| s.is_active }
      respond_to do |format|
        format.html { @staff_list = @staff_list.paginate(:page => params[:page], :per_page => 20)}
        format.xml  { render :xml => @staff_list }
      end
    end
  end
  
  # GET /users
  # GET /users.xml
  # GET /users.json
  # GET /users.json?role=X  (get users by roles for single role 'X')
  # GET /users.json?role[]=X&role[]=Y   (get users by roles for multiple roles 'X' or 'Y')
  # GET /users.json?first_name=X&last_name=Y&username=Z   (get users by first_name 'X' and last_name 'Y' and username 'Z')
  # GET /users.json?first_name=X&last_name=Y&username=Z&operator=OR   (get users by first_name 'X' or last_name 'Y' or username 'Z')

  def users
    if permit?(Role::USER_ADMINISTRATOR)
      params[:page] ||= 1
      if params[:role]
        @users = Staff.find_by_role(params[:role])
      elsif params[:first_name] || params[:last_name] || params[:username]
        @users = Staff.where(construct_condition_string(params))
      else
        all_users = Staff.all
        @users = all_users.select(&:username).sort_by(&:username) + all_users.reject(&:username)
      end
      respond_to do |format|
        format.html { @users = @users.paginate(:page => params[:page], :per_page => 20)}
        format.xml  { render :xml => @users }
        format.json { render :json => @users }
      end
    else
      throw :warden
    end
  end

  # GET /staff/1
  # GET /staff/1.xml
  def show
    @staff = find_staff
    add_breadcrumb "#{@staff.display_name}", staff_path(@staff) unless same_as_current_user(@staff)
    respond_to do |format|
      format.html { render :layout => "staff_information" }
      format.xml  { render :xml => @staff }
      format.json { render :json => @staff }
    end
  end

  # GET /staff/new
  # GET /staff/new.xml
  # GET /users/new
  def new
    if permit?(Role::USER_ADMINISTRATOR)
      add_breadcrumb "new user", :new_users_path
      @user = Staff.new
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @user }
      end
    end
  end

  # GET /staff/1/edit
  def edit
    @staff = Staff.find(params[:id])
    add_breadcrumb "Edit - #{@staff.display_name}", edit_staff_path(@staff) unless same_as_current_user(@staff)
    respond_to do |format|
      format.html { render :layout => "staff_information" }
      format.xml  { render :xml => @staff }
    end
  end
  
  # GET /users/1/edit
  def edit_user
    if permit?(Role::USER_ADMINISTRATOR)
      @user = Staff.find(params[:id])
      add_breadcrumb "Edit user[#{@user.username} - #{@user.name}]", edit_users_path(@user)
    end
  end

  # POST /staff
  # POST /staff.xml
  def create
    if permit?(Role::USER_ADMINISTRATOR)
      @user = Staff.new(params[:staff])

      respond_to do |format|
        if @user.save
          format.html { redirect_to(users_path) }
          format.xml  { render :xml => @user, :status => :created, :location => @user }
        else               
          format.html { render :action => "new" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /staff/1
  # PUT /staff/1.xml
  def update
    @staff = Staff.find(params[:id])
    respond_to do |format|
      if @staff.update_attributes(params[:staff])
        @staff.expenses_without_pay.each do |expense|
          expense.rate = @staff.hourly_rate
          expense.save!
        end
        format.html {
          if @staff.id == @current_staff.id
            if params[:return_path] == "users_path"
              render_user_list
            else
              render_staff
            end
          elsif permit?(Role::STAFF_SUPERVISOR)
            if permit?(Role::USER_ADMINISTRATOR)
              if params[:return_path] == "staff_index_path"
                render_staff_list
              else
                render_user_list
              end
            else
              render_staff_list
            end 
          elsif permit?(Role::USER_ADMINISTRATOR)
            render_user_list
          else
            render_staff
          end
        }
        format.json { head :ok }
        format.xml  { head :ok }
      else
        format.html { 
          if params[:return_path] == "users_path"
            @user = @staff
            render :action => "edit_user", :location => @user
          else
            render :action => "edit"
          end
        }
        format.json { render :json => @staff.errors, :status => :unprocessable_entity }
        format.xml  { render :xml => @staff.errors, :status => :unprocessable_entity }
      end
    end
  end

  private
  def check_staff_access
    @staff = find_staff
    check_user_access(@staff)
    if same_as_current_user(@staff)
      set_tab :my_info
    else
      set_tab :admin
      add_breadcrumb "Admin", :administration_index_path
      add_breadcrumb "Manage staff details", :staff_index_path
    end
  end
  
  def find_staff
    begin
      staff = Staff.find_by_username(params[:id]) || Staff.find_by_numeric_id(params[:id]) || Staff.find(params[:id]) 
    rescue ActiveRecord::RecordNotFound
      render :status => :not_found, :text => "Unknown Staff #{params[:id]}"
    end
  end
  
  def render_staff
    redirect_to(@staff, :notice => 'Staff was successfully updated.') 
  end
  
  def render_staff_list
    redirect_to(staff_index_path)
  end
  
  def render_user_list
    redirect_to(users_path)
  end
  
  def construct_condition_string(params)
    operator = params[:operator] =~ /OR/ ? " OR " : " AND "
    if params[:first_name]
      conditions = get_search_string(:first_name, params[:first_name])
      if params[:last_name]
        conditions << operator
        conditions << get_search_string(:last_name, params[:last_name])
      end
      if params[:username]
        conditions << operator
        conditions << get_search_string(:username, params[:username])
      end
    elsif params[:last_name]
      conditions = get_search_string(:last_name, params[:last_name])
      if params[:username]
        conditions << operator
        conditions << get_search_string(:username, params[:username])
      end
    elsif params[:username]
      conditions = get_search_string(:username, params[:username])
    end
    conditions
  end
  
  def get_search_string(key, value)
    Staff.arel_table[key].matches("%#{value}%").to_sql
  end
end
