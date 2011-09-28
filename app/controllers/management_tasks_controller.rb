class ManagementTasksController < SecuredController
  set_tab :time_and_expenses
  layout :tasks_layout
  before_filter :check_staff_access, :only => %w(new edit) 
  # GET /management_tasks/new
  # GET /management_tasks/new.xml
  def new
    params[:page] ||= 1
    @management_tasks = Staff.find(params[:staff_id]).management_tasks.sort_by(&:task_date).reverse.paginate(:page => params[:page], :per_page => 20)
    @staff = Staff.find(params[:staff_id])
    @management_task = @staff.management_tasks.build
    add_breadcrumb "new task", new_staff_management_task_path(@staff)
   
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @management_task }
    end
  end

  # GET /management_tasks/1/edit
  def edit
    @staff = Staff.find(params[:staff_id])
    params[:page] ||= 1
    @management_tasks = @staff.management_tasks.sort_by(&:task_date).reverse.paginate(:page => params[:page], :per_page => 20)
    @management_task = @staff.management_tasks.find(params[:id])
    add_breadcrumb "edit task", edit_staff_management_task_path(@staff, @management_task)
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @management_task }
    end
  end

  # POST /management_tasks
  # POST /management_tasks.xml
  def create
    @staff = Staff.find(params[:staff_id])
    @management_task_temp  = ManagementTask.new(params[:management_task])
    @start_date = @management_task_temp.task_date.monday unless @management_task_temp.task_date.blank?
    
    @staff_weekly_expense = StaffWeeklyExpense.find_by_week_start_date_and_staff_id(@start_date, @staff)
    if @staff_weekly_expense.nil?
       @staff_weekly_expense = @staff.staff_weekly_expenses.build
       @staff_weekly_expense.week_start_date = @start_date
       @staff_weekly_expense.rate = @staff.hourly_rate
       @staff_weekly_expense.save
    end
    @management_task = @staff_weekly_expense.management_tasks.build(params[:management_task])
       
    respond_to do |format|
      if @management_task.save
        format.html { redirect_to(new_staff_management_task_path(@staff), :notice => 'Management task was successfully created.') }
        format.xml  { render :xml => @management_task, :status => :created, :location => @management_task }
      else
        @management_tasks = @staff.management_tasks.sort_by(&:task_date).reverse.paginate(:page => params[:page], :per_page => 20)
        format.html { render :action => "new", :management_tasks => @management_tasks }
        format.xml  { render :xml => @management_task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /management_tasks/1
  # PUT /management_tasks/1.xml
  def update
    @management_task = ManagementTask.find(params[:id])
    respond_to do |format|
      if @management_task.update_attributes(params[:management_task])
        format.html { redirect_to(new_staff_management_task_path(@staff), :notice => 'Management task was successfully updated.') }
        format.xml  { head :ok }
      else
        @management_tasks = @staff.management_tasks.sort_by(&:task_date).reverse.paginate(:page => params[:page], :per_page => 20)
        format.html { render :action => "edit", :management_tasks => @management_tasks }
        format.xml  { render :xml => @management_task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /management_tasks/1
  # DELETE /management_tasks/1.xml
  def destroy
    @staff = Staff.find(params[:staff_id])
    @management_task = @staff.management_tasks.find(params[:id])
    @management_task.destroy

    respond_to do |format|
      format.html { redirect_to(new_staff_management_task_path(@staff))}
      format.xml  { head :ok }
    end
  end
  private
  
  def check_staff_access
    @staff = Staff.find(params[:staff_id])
    check_user_access(@staff)
    if (@staff.id == @current_staff.id) 
      set_tab :time_and_expenses
    else
      # layout "layouts/staff_information"
      set_tab :admin
      set_tab :time_and_expenses, :vertical
      add_breadcrumb "admin", :administration_index_path
      add_breadcrumb "manage staff", :staff_index_path
    end
  end
  
  def tasks_layout
    @staff = Staff.find(params[:staff_id])
    if (@staff.id == @current_staff.id) 
      "layouts/application"
    else
      "layouts/staff_information"
    end
  end
end
