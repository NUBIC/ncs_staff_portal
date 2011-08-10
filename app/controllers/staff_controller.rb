class StaffController < SecuredController
  layout "layouts/staff_information"
  set_tab :general_info, :vertical
  before_filter :check_staff_access,  :except => [:index, :new]

  # GET /staff
  # GET /staff.xml
  def index
    set_tab :staff
    params[:page] ||= 1
    @staff_list = Staff.all.sort_by(&:username).paginate(:page => params[:page], :per_page => 20)
    
    respond_to do |format|
      format.html  { render :layout => "application"}
      format.xml  { render :xml => @staff_list }
    end

  end

  # GET /staff/1
  # GET /staff/1.xml
  def show
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @staff }
    end
  end

  # GET /staff/new
  # GET /staff/new.xml
  def new
    throw :warden unless permit?(:supervisor)
    @staff = Staff.new
    set_tab :staff
    respond_to do |format|
      format.html { render :layout => "application"}
      format.xml  { render :xml => @staff }
    end
  end

  # GET /staff/1/edit
  def edit
  end

  # POST /staff
  # POST /staff.xml
  def create
    @staff = Staff.new(params[:staff])

    respond_to do |format|
      if @staff.save
        format.html { redirect_to(staff_index_path, :notice => 'Staff was successfully created.') }
        format.xml  { render :xml => @staff, :status => :created, :location => @staff }
      else               
        format.html { render :action => "new" }
        format.xml  { render :xml => @staff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /staff/1
  # PUT /staff/1.xml
  def update
    @staff = Staff.find(params[:id])

    respond_to do |format|
      if @staff.update_attributes(params[:staff])
        format.html { redirect_to(@staff, :notice => 'Staff was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
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
  
  def check_staff_access
    @staff = Staff.find(params[:id])
    check_user_access(@staff)
    # TODO: write in helper file and reuse everywhere 
    if (@staff.id == @current_staff.id) 
      set_tab :my_info
    else
      set_tab :staff
    end
  end
end
