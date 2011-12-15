class StaffController < SecuredController
  layout "layouts/application"
  before_filter :check_staff_access,  :only => %w(show edit) 
  
  set_tab :general_info, :vertical
  set_tab :admin, :only => %w(index users new edit_user)

  add_breadcrumb "Admin", :administration_index_path, :only => %w(index users new edit_user) 
  add_breadcrumb "Administer user accounts", :users_staff_index_path, :only => %w(new users edit_user)
  add_breadcrumb "Manage staff details", :staff_index_path, :only => %w(index)


  # GET /staff
  # GET /staff.xml
  def index
    if permit?(Role::STAFF_SUPERVISOR)
      params[:page] ||= 1
      @staff_list = @current_staff.visible_employees.sort_by(&:username).select { |s| s.is_active }.paginate(:page => params[:page], :per_page => 20)
      
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @staff_list }
      end
    end
  end
  
  def users
    if permit?(Role::USER_ADMINISTRATOR)
      params[:page] ||= 1
      @users = Staff.all.sort_by(&:username).paginate(:page => params[:page], :per_page => 20)
    
      respond_to do |format|
        format.html  
        format.xml  { render :xml => @users }
      end
    end
  end

  # GET /staff/1
  # GET /staff/1.xml
  def show
    @staff = find_staff
    respond_to do |format|
      format.html { 
        render :layout => "staff_information" 
        add_breadcrumb "#{@staff.name}", staff_path(@staff) unless same_as_current_user(@staff)
      }
      format.xml  { render :xml => @staff }
      format.json { render :json => @staff }
    end
  end

  # GET /staff/new
  #  GET /staff/new.xml
  def new
    if permit?(Role::USER_ADMINISTRATOR)
      add_breadcrumb "new user", :new_staff_path
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
    add_breadcrumb "#{@staff.name}", edit_staff_path(@staff) unless same_as_current_user(@staff)
    respond_to do |format|
      format.html { render :layout => "staff_information" }
      format.xml  { render :xml => @staff }
    end
  end
  
  def edit_user
    if permit?(Role::USER_ADMINISTRATOR)
      @user = Staff.find(params[:id])
      add_breadcrumb "#{@user.name}", edit_user_staff_path(@user)
    end
  end

  # POST /staff
  # POST /staff.xml
  def create
    if permit?(Role::USER_ADMINISTRATOR)
      @user = Staff.new(params[:staff])

      respond_to do |format|
        if @user.save
          format.html { redirect_to(users_staff_index_path) }
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
          if permit?(Role::STAFF_SUPERVISOR)
            if permit?(Role::USER_ADMINISTRATOR)
              if @staff.id == @current_staff.id
                render_staff
              elsif params[:return_path] == "staff_index_path"
                render_staff_list
              elsif params[:return_path] == "users_staff_index_path"
                render_user_list
              end
            elsif @staff.id == @current_staff.id
              render_staff
            else
              render_staff_list
            end
          elsif permit?(Role::USER_ADMINISTRATOR)
            render_user_list
          else
            render_staff
          end
        }
        format.xml  { head :ok }
      else
        format.html { 
          if permit?(Role::STAFF_SUPERVISOR)
            if permit?(Role::USER_ADMINISTRATOR)
              if params[:return_path] == "staff_index_path"
                render :action => "edit", :location => @staff
              elsif params[:return_path] == "users_staff_index_path"
                @user = @staff
                render :action => "edit_user", :location => @user
              end
            else
              render :action => "edit", :location => @staff
            end
          elsif permit?(Role::USER_ADMINISTRATOR)
            @user = @staff
            render :action => "edit_user", :location => @user
          else
            render :action => "edit", :location => @staff
          end
          
        }
        format.xml  { render :xml => @staff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /staff/1
  # DELETE /staff/1.xml
  def destroy
    @staff = Staff.find(params[:id])
    @staff.destroy

    respond_to do |format|
      format.html { redirect_to(staff_index_url) }
      format.xml  { head :ok }
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
    staff = Staff.find_by_username(params[:id]) || Staff.find(params[:id])
    if staff
      staff
    else
      raise "Staff does not exist."
    end
  end
  
  def render_staff
    redirect_to(@staff, :notice => 'Staff was successfully updated.') 
  end
  
  def render_staff_list
    redirect_to(staff_index_path)
  end
  
  def render_user_list
    redirect_to(users_staff_index_path)
  end
end
