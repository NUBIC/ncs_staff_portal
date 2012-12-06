class DataCollectionTasksController < StaffAuthorizedController
  set_tab :time_and_expenses
  layout :tasks_layout

  before_filter :load_staff
  before_filter :assert_staff
  before_filter :check_requested_staff_visibility
  before_filter :check_staff_access, :only => %w(new edit)

  # GET /data_collection_tasks/new
  # GET /data_collection_tasks/new.xml
  def new
    params[:page] ||= 1
    @data_collection_tasks = @staff.data_collection_tasks.sort_by(&:task_date).reverse.paginate(:page => params[:page], :per_page => 20)
    @data_collection_task = @staff.data_collection_tasks.build

    respond_to do |format|
      format.html
      format.xml  { render :xml => @data_collection_task }
    end
  end

  # GET /data_collection_tasks/1/edit
  def edit
    params[:page] ||= 1
    @data_collection_tasks = @staff.data_collection_tasks.sort_by(&:task_date).reverse.paginate(:page => params[:page], :per_page => 20)
    @data_collection_task = @staff.data_collection_tasks.find(params[:id])
    respond_to do |format|
      format.html
      format.xml  { render :xml => @data_collection_task }
    end
  end

  # POST /data_collection_tasks
  # POST /data_collection_tasks.xml
  def create
    data_collection_task_temp = DataCollectionTask.new(params[:data_collection_task])
    start_date = data_collection_task_temp.task_date.beginning_of_week unless data_collection_task_temp.task_date.blank?
    staff_weekly_expense = StaffWeeklyExpense.find_or_create_by_week_start_date_and_staff_id(start_date, @staff.id, :rate => @staff.hourly_rate)
    @data_collection_task = staff_weekly_expense.data_collection_tasks.build(params[:data_collection_task])

    respond_to do |format|
      if @data_collection_task.save
        format.html { redirect_to(new_staff_data_collection_task_path(@staff.numeric_id), :notice => 'data_collection_task was successfully created.') }
        format.xml  { render :xml => @data_collection_task, :status => :created, :location => @data_collection_task }
      else
        @data_collection_tasks = @staff.data_collection_tasks.sort_by(&:task_date).reverse.paginate(:page => params[:page], :per_page => 20)
        format.html { render :action => "new", :data_collection_tasks => @data_collection_tasks }
        format.xml  { render :xml => @data_collection_task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /data_collection_tasks/1
  # PUT /data_collection_tasks/1.xml
  def update
    @data_collection_task = DataCollectionTask.find(params[:id])
    data_collection_task_temp  = DataCollectionTask.new(params[:data_collection_task])
    unless data_collection_task_temp.task_date == @data_collection_task.task_date
      start_date = data_collection_task_temp.task_date.beginning_of_week unless data_collection_task_temp.task_date.blank?
      staff_weekly_expense = StaffWeeklyExpense.find_or_create_by_week_start_date_and_staff_id(start_date, @staff.id, :rate => @data_collection_task.staff_weekly_expense.rate)
      unless @data_collection_task.staff_weekly_expense == staff_weekly_expense
        @data_collection_task.staff_weekly_expense = staff_weekly_expense
      end
    end
    respond_to do |format|
      if @data_collection_task.update_attributes(params[:data_collection_task])
        format.html { redirect_to(new_staff_data_collection_task_path(@staff.numeric_id), :notice => 'data_collection_task was successfully updated.') }
        format.xml  { head :ok }
      else
        @data_collection_tasks = @staff.data_collection_tasks.sort_by(&:task_date).reverse.paginate(:page => params[:page], :per_page => 20)
        format.html { render :action => "edit", :data_collection_tasks => @data_collection_tasks }
        format.xml  { render :xml => @data_collection_task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /data_collection_tasks/1
  # DELETE /data_collection_tasks/1.xml
  def destroy
    @data_collection_task = @staff.data_collection_tasks.find(params[:id])
    @data_collection_task.destroy

    respond_to do |format|
      format.html { redirect_to(new_staff_data_collection_task_path(@staff.numeric_id))}
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
      add_breadcrumb "#{@staff.display_name}", staff_path(@staff.numeric_id)
    end
  end

  def tasks_layout
    same_as_current_user(@staff) ? "layouts/application" : "layouts/staff_information"
  end
end
