class ManagementTasksController < StaffAuthorizedController
  set_tab :time_and_expenses
  layout :tasks_layout

  before_filter :load_staff
  before_filter :assert_staff
  before_filter :check_requested_staff_visibility
  before_filter :check_staff_access, :only => %w(new edit) 

  # GET /management_tasks/new
  # GET /management_tasks/new.xml
  def new
    params[:page] ||= 1
    @management_tasks = @staff.management_tasks.sort_by(&:task_date).reverse.paginate(:page => params[:page], :per_page => 20)
    @management_task = @staff.management_tasks.build
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @management_task }
    end
  end

  # GET /management_tasks/1/edit
  def edit
    params[:page] ||= 1
    @management_tasks = @staff.management_tasks.sort_by(&:task_date).reverse.paginate(:page => params[:page], :per_page => 20)
    @management_task = @staff.management_tasks.find(params[:id])
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @management_task }
    end
  end

  # POST /management_tasks
  # POST /management_tasks.xml
  def create
    management_task_temp  = ManagementTask.new(params[:management_task])
    start_date = management_task_temp.task_date.beginning_of_week unless management_task_temp.task_date.blank?
    staff_weekly_expense = StaffWeeklyExpense.find_or_create_by_week_start_date_and_staff_id(start_date, @staff.id, :rate => @staff.hourly_rate) 
    @management_task = staff_weekly_expense.management_tasks.build(params[:management_task])
       
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
    management_task_temp  = ManagementTask.new(params[:management_task])
    unless management_task_temp.task_date == @management_task.task_date
      start_date = management_task_temp.task_date.beginning_of_week unless management_task_temp.task_date.blank?
      staff_weekly_expense = StaffWeeklyExpense.find_or_create_by_week_start_date_and_staff_id(start_date, @staff.id, :rate => @management_task.staff_weekly_expense.rate)
      unless @management_task.staff_weekly_expense == staff_weekly_expense
        @management_task.staff_weekly_expense = staff_weekly_expense
      end 
    end

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
    @management_task = @staff.management_tasks.find(params[:id])
    @management_task.destroy

    respond_to do |format|
      format.html { redirect_to(new_staff_management_task_path(@staff))}
      format.xml  { head :ok }
    end
  end
  private
  
  def check_staff_access
    if same_as_current_user(@staff)
      set_tab :time_and_expenses
    else
      set_tab :admin
      set_tab :time_and_expenses, :vertical
      add_breadcrumb "Admin", :administration_index_path
      add_breadcrumb "Manage staff details", :staff_index_path
      add_breadcrumb "#{@staff.display_name}", staff_path(@staff)
    end
  end
  
  def tasks_layout
    same_as_current_user(@staff) ? "layouts/application" : "layouts/staff_information"
  end
end
