class StaffCertTrainingsController < SecuredController
  set_tab :staff

  # GET /staff_cert_trainings/new
  # GET /staff_cert_trainings/new.xml
  def new
    @staff_cert_trainings = Staff.find(params[:staff_id]).staff_cert_trainings
    @staff = Staff.find(params[:staff_id])
    @staff_cert_training = @staff.staff_cert_trainings.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @staff_cert_training }
    end
  end

  # GET /staff_cert_trainings/1/edit
  def edit
    @staff = Staff.find(params[:staff_id])
    @staff_cert_trainings = @staff.staff_cert_trainings
    @staff_cert_training = @staff.staff_cert_trainings.find(params[:id])
  end

  # POST /staff_cert_trainings
  # POST /staff_cert_trainings.xml
  def create
    @staff = Staff.find(params[:staff_id])
    @staff_cert_training = @staff.staff_cert_trainings.build(params[:staff_cert_training])

    respond_to do |format|
      if @staff_cert_training.save
        format.html { redirect_to(new_staff_staff_cert_training_path(@staff), :notice => 'Staff cert training was successfully created.') }
        format.xml  { render :xml => @staff_cert_training, :status => :created, :location => @staff_cert_training }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @staff_cert_training.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /staff_cert_trainings/1
  # PUT /staff_cert_trainings/1.xml
  def update
    @staff = Staff.find(params[:staff_id])
    @staff_cert_training = @staff.staff_cert_trainings.find(params[:id])

    respond_to do |format|
      if @staff_cert_training.update_attributes(params[:staff_cert_training])
        format.html { redirect_to(new_staff_staff_cert_training_path(@staff), :notice => 'Staff cert training was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @staff_cert_training.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /staff_cert_trainings/1
  # DELETE /staff_cert_trainings/1.xml
  def destroy
    @staff = Staff.find(params[:staff_id])
    @staff_cert_training = @staff.staff_cert_trainings.find(params[:id])
    @staff_cert_training.destroy

    respond_to do |format|
      format.html { redirect_to(new_staff_staff_cert_training_path(@staff))}
      format.xml  { head :ok }
    end
  end
end
