class StaffCertTrainingsController < StaffAuthorizedController
  layout "layouts/staff_information"
  set_tab :cert_trainings, :vertical

  before_filter :load_staff
  before_filter :assert_staff
  before_filter :check_requested_staff_visibility
  before_filter :check_staff_access

  # GET /staff_cert_trainings/new
  # GET /staff_cert_trainings/new.xml
  def new
    params[:page] ||= 1
    @staff_cert_trainings = @staff.staff_cert_trainings.paginate(:page => params[:page], :per_page => 20)
    @staff_cert_training = @staff.staff_cert_trainings.build
    add_breadcrumb "Certificates/Trainings", new_staff_staff_cert_training_path(@staff) unless same_as_current_user(@staff)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @staff_cert_training }
    end
  end

  # GET /staff_cert_trainings/1/edit
  def edit
    params[:page] ||= 1
    @staff_cert_trainings = @staff.staff_cert_trainings.paginate(:page => params[:page], :per_page => 20)
    @staff_cert_training = @staff.staff_cert_trainings.find(params[:id])
    add_breadcrumb "Certificates/Trainings", edit_staff_staff_cert_training_path(@staff, @staff_cert_training) unless same_as_current_user(@staff)
  end

  # POST /staff_cert_trainings
  # POST /staff_cert_trainings.xml
  def create
    @staff_cert_training = @staff.staff_cert_trainings.build(params[:staff_cert_training])
    respond_to do |format|
      if @staff_cert_training.save
        format.html { redirect_to(new_staff_staff_cert_training_path(@staff), :notice => 'Staff cert training was successfully created.') }
        format.xml  { render :xml => @staff_cert_training, :status => :created, :location => @staff_cert_training }
      else
        @staff_cert_trainings = @staff.staff_cert_trainings.paginate(:page => params[:page], :per_page => 20)
        format.html { render :action => "new", :staff_cert_trainings => @staff_cert_trainings }
        format.xml  { render :xml => @staff_cert_training.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /staff_cert_trainings/1
  # PUT /staff_cert_trainings/1.xml
  def update
    @staff_cert_training = @staff.staff_cert_trainings.find(params[:id])
    respond_to do |format|
      if @staff_cert_training.update_attributes(params[:staff_cert_training])
        format.html { redirect_to(new_staff_staff_cert_training_path(@staff), :notice => 'Staff cert training was successfully updated.') }
        format.xml  { head :ok }
      else
        @staff_cert_trainings = @staff.staff_cert_trainings.paginate(:page => params[:page], :per_page => 20)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @staff_cert_training.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /staff_cert_trainings/1
  # DELETE /staff_cert_trainings/1.xml
  def destroy
    @staff_cert_training = @staff.staff_cert_trainings.find(params[:id])
    @staff_cert_training.destroy

    respond_to do |format|
      format.html { redirect_to(new_staff_staff_cert_training_path(@staff))}
      format.xml  { head :ok }
    end
  end

  def check_staff_access
    # TODO: write in helper file and reuse everywhere
    if @staff && (@staff.id == @current_staff.id)
      set_tab :my_info
    else
      set_tab :admin
      add_breadcrumb "Admin", :administration_index_path
      add_breadcrumb "Manage staff details", :staff_index_path
      add_breadcrumb "#{@staff.display_name}", staff_path(@staff)
    end
  end
end
