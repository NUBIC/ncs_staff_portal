class DataCollectionTasksController < SecuredController
  set_tab :time_and_expenses
  layout :tasks_layout
  before_filter :check_staff_access, :only => %w(new edit) 
  # GET /management_tasks/new
  # GET /management_tasks/new.xml
  def new
    params[:page] ||= 1
    @data_collection_tasks = Staff.find(params[:staff_id]).data_collection_tasks.sort_by(&:task_date).reverse.paginate(:page => params[:page], :per_page => 20)
    @staff = Staff.find(params[:staff_id])
    @data_collection_task = @staff.data_collection_tasks.build

    respond_to do |format|
      format.html 
      format.xml  { render :xml => @data_collection_task }
    end
  end

  # GET /management_tasks/1/edit
  def edit
    @staff = Staff.find(params[:staff_id])
    params[:page] ||= 1
    @data_collection_tasks = @staff.data_collection_tasks.sort_by(&:task_date).reverse.paginate(:page => params[:page], :per_page => 20)
    @data_collection_task = @staff.data_collection_tasks.find(params[:id])
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @data_collection_task }
    end
  end

  # POST /management_tasks
  # POST /management_tasks.xml
  def create
    @staff = Staff.find(params[:staff_id])
    @data_collection_task_temp  = DataCollectionTask.new(params[:data_collection_task])
    @start_date = @data_collection_task_temp.task_date.monday unless @data_collection_task_temp.task_date.blank?

    @staff_weekly_expense = StaffWeeklyExpense.find_by_week_start_date_and_staff_id(@start_date, @staff)
    if @staff_weekly_expense.nil?
       @staff_weekly_expense = @staff.staff_weekly_expenses.build
       @staff_weekly_expense.week_start_date = @start_date
       @staff_weekly_expense.rate = @staff.hourly_rate
       @staff_weekly_expense.save
    end
    @data_collection_task = @staff_weekly_expense.data_collection_tasks.build(params[:data_collection_task])

    respond_to do |format|
      if @data_collection_task.save
        format.html { redirect_to(new_staff_data_collection_task_path(@staff), :notice => 'data_collection_task was successfully created.') }
        format.xml  { render :xml => @data_collection_task, :status => :created, :location => @data_collection_task }
      else
        @data_collection_tasks = @staff.data_collection_tasks.sort_by(&:task_date).reverse.paginate(:page => params[:page], :per_page => 20)
        format.html { render :action => "new", :data_collection_tasks => @data_collection_tasks }
        format.xml  { render :xml => @data_collection_task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /management_tasks/1
  # PUT /management_tasks/1.xml
  def update
    @data_collection_task = DataCollectionTask.find(params[:id])
    respond_to do |format|
      if @data_collection_task.update_attributes(params[:data_collection_task])
        format.html { redirect_to(new_staff_data_collection_task_path(@staff), :notice => 'data_collection_task was successfully updated.') }
        format.xml  { head :ok }
      else
        @data_collection_tasks = @staff.data_collection_tasks.sort_by(&:task_date).reverse.paginate(:page => params[:page], :per_page => 20)
        format.html { render :action => "edit", :data_collection_tasks => @data_collection_tasks }
        format.xml  { render :xml => @data_collection_task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /management_tasks/1
  # DELETE /management_tasks/1.xml
  def destroy
    @staff = Staff.find(params[:staff_id])
    @data_collection_task = @staff.data_collection_tasks.find(params[:id])
    @data_collection_task.destroy

    respond_to do |format|
      format.html { redirect_to(new_staff_data_collection_task_path(@staff))}
      format.xml  { head :ok }
    end
  end
  
  private

  def check_staff_access
    @staff = Staff.find(params[:staff_id])
    check_user_access(@staff)
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
    @staff = Staff.find(params[:staff_id])
    same_as_current_user(@staff) ? "layouts/application" : "layouts/staff_information"
  end
end
