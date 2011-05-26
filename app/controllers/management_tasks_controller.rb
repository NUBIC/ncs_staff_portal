class ManagementTasksController < SecuredController
  set_tab :time_and_expenses
  before_filter :check_staff_access
  # GET /management_tasks/new
  # GET /management_tasks/new.xml
  def new
    @management_tasks = Staff.find(params[:staff_id]).management_tasks.sort_by(&:task_date).reverse
    @staff = Staff.find(params[:staff_id])
    @management_task = @staff.management_tasks.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @management_task }
    end
  end

  # GET /management_tasks/1/edit
  def edit
    @staff = Staff.find(params[:staff_id])
    @management_tasks = @staff.management_tasks
    @management_task = @staff.management_tasks.find(params[:id])
  end

  # POST /management_tasks
  # POST /management_tasks.xml
  def create
    @staff = Staff.find(params[:staff_id])
    @management_task_temp  = ManagementTask.new(params[:management_task])
    @start_date = @management_task_temp.task_date.monday
    @staff_weekly_expense = StaffWeeklyExpense.find_by_week_start_date_and_staff_id(@start_date, @staff)
    if @staff_weekly_expense.nil?
       @staff_weekly_expense = @staff.staff_weekly_expenses.build
       @staff_weekly_expense.week_start_date = @start_date
       @staff_weekly_expense.save
    end
    @management_task = @staff_weekly_expense.management_tasks.build(params[:management_task])
       
    respond_to do |format|
      if @management_task.save
        format.html { redirect_to(new_staff_management_task_path(@staff), :notice => 'Management task was successfully created.') }
        format.xml  { render :xml => @management_task, :status => :created, :location => @management_task }
      else
        format.html { render :action => "new" }
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
        format.html { render :action => "edit" }
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
  def check_staff_access
    @staff = Staff.find(params[:staff_id])
    check_user_access(@staff)
  end
end
