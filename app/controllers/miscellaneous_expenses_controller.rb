class MiscellaneousExpensesController < StaffAuthorizedController
  set_tab :time_and_expenses
  layout :tasks_layout

  before_filter :load_staff
  before_filter :assert_staff
  before_filter :check_requested_staff_visibility
  before_filter :check_staff_access, :only => %w(new edit)

  # GET /miscellaneous_expenses/new
  # GET /miscellaneous_expenses/new.xml
  def new
    params[:page] ||= 1
    @miscellaneous_expenses = @staff.miscellaneous_expenses.sort_by(&:expense_date).reverse.paginate(:page => params[:page], :per_page => 20)
    @miscellaneous_expense = @staff.miscellaneous_expenses.build

    respond_to do |format|
      format.html
      format.xml  { render :xml => @miscellaneous_expense }
    end
  end

  # GET /miscellaneous_expenses/1/edit
  def edit
    params[:page] ||= 1
    @miscellaneous_expenses = @staff.miscellaneous_expenses.sort_by(&:expense_date).reverse.paginate(:page => params[:page], :per_page => 20)
    @miscellaneous_expense = @staff.miscellaneous_expenses.find(params[:id])
    respond_to do |format|
      format.html
      format.xml  { render :xml => @miscellaneous_expense }
    end
  end

  # POST /miscellaneous_expenses
  # POST /miscellaneous_expenses.xml
  def create
    miscellaneous_expense_temp = MiscellaneousExpense.new(params[:miscellaneous_expense])
    start_date = miscellaneous_expense_temp.expense_date.beginning_of_week unless miscellaneous_expense_temp.expense_date.blank?
    staff_weekly_expense = StaffWeeklyExpense.find_or_create_by_week_start_date_and_staff_id(start_date, @staff.id, :rate => @staff.hourly_rate)
    @miscellaneous_expense = staff_weekly_expense.miscellaneous_expenses.build(params[:miscellaneous_expense])

    respond_to do |format|
      if @miscellaneous_expense.save
        format.html { redirect_to(new_staff_miscellaneous_expense_path(@staff.numeric_id), :notice => 'miscellaneous_expense was successfully created.') }
        format.xml  { render :xml => @miscellaneous_expense, :status => :created, :location => @miscellaneous_expense }
      else
        @miscellaneous_expenses = @staff.miscellaneous_expenses.sort_by(&:expense_date).reverse.paginate(:page => params[:page], :per_page => 20)
        format.html { render :action => "new", :miscellaneous_expenses => @miscellaneous_expenses }
        format.xml  { render :xml => @miscellaneous_expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /miscellaneous_expenses/1
  # PUT /miscellaneous_expenses/1.xml
  def update
    @miscellaneous_expense = MiscellaneousExpense.find(params[:id])
    miscellaneous_expense_temp  = MiscellaneousExpense.new(params[:miscellaneous_expense])
    unless miscellaneous_expense_temp.expense_date == @miscellaneous_expense.expense_date
      start_date = miscellaneous_expense_temp.expense_date.beginning_of_week unless miscellaneous_expense_temp.expense_date.blank?
      staff_weekly_expense = StaffWeeklyExpense.find_or_create_by_week_start_date_and_staff_id(start_date, @staff.id, :rate => @miscellaneous_expense.staff_weekly_expense.rate)
      unless @miscellaneous_expense.staff_weekly_expense == staff_weekly_expense
        @miscellaneous_expense.staff_weekly_expense = staff_weekly_expense
      end
    end
    respond_to do |format|
      if @miscellaneous_expense.update_attributes(params[:miscellaneous_expense])
        format.html { redirect_to(new_staff_miscellaneous_expense_path(@staff.numeric_id), :notice => 'miscellaneous_expense was successfully updated.') }
        format.xml  { head :ok }
      else
        @miscellaneous_expenses = @staff.miscellaneous_expenses.sort_by(&:expense_date).reverse.paginate(:page => params[:page], :per_page => 20)
        format.html { render :action => "edit", :miscellaneous_expenses => @miscellaneous_expenses }
        format.xml  { render :xml => @miscellaneous_expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /miscellaneous_expenses/1
  # DELETE /miscellaneous_expenses/1.xml
  def destroy
    @miscellaneous_expense = @staff.miscellaneous_expenses.find(params[:id])
    @miscellaneous_expense.destroy

    respond_to do |format|
      format.html { redirect_to(new_staff_miscellaneous_expense_path(@staff.numeric_id))}
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
