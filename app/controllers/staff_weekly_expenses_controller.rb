class StaffWeeklyExpensesController < SecuredController
  set_tab :time_and_expenses

  # GET /staff_weekly_expenses
  # GET /staff_weekly_expenses.xml
  def index
    params[:page] ||= 1
    @staff_weekly_expenses = StaffWeeklyExpense.visible_expenses(@current_staff.visible_employees.map(&:id)).sort_by(&:week_start_date).reverse.paginate(:page => params[:page], :per_page => 20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @staff_weekly_expenses }
    end
  end

  # GET /staff_weekly_expenses/1
  # GET /staff_weekly_expenses/1.xml
  def show
    @staff_weekly_expense = Staff.find(params[:staff_id]).staff_weekly_expenses.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @staff_weekly_expense }
    end
  end

  # GET /staff_weekly_expenses/new
  # GET /staff_weekly_expenses/new.xml
  def new
    @staff = Staff.find(params[:staff_id])
    @staff_weekly_expense = @staff.staff_weekly_expenses.build
    @staff_weekly_expense.management_tasks.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @staff_weekly_expense }
    end
  end

  # GET /staff_weekly_expenses/1/edit
  def edit
    @staff = Staff.find(params[:staff_id])
    @staff_weekly_expense = @staff.staff_weekly_expenses.find(params[:id])
  end

  # POST /staff_weekly_expenses
  # POST /staff_weekly_expenses.xml
  def create
    @staff = Staff.find(params[:staff_id])
    @staff_weekly_expense = @staff.staff_weekly_expenses.build(params[:staff_weekly_expense])

    respond_to do |format|
      if @staff_weekly_expense.save
        format.html { redirect_to(staff_staff_weekly_expense_path(params[:staff_id],@staff_weekly_expense), :notice => 'Staff weekly expense was successfully created.') }
        format.xml  { render :xml => @staff_weekly_expense, :status => :created, :location => @staff_weekly_expense }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @staff_weekly_expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /staff_weekly_expenses/1
  # PUT /staff_weekly_expenses/1.xml
  def update
    @staff = Staff.find(params[:staff_id])
    @staff_weekly_expense = @staff.staff_weekly_expenses.find(params[:id])

    respond_to do |format|
      if @staff_weekly_expense.update_attributes(params[:staff_weekly_expense])
        format.html { redirect_to(staff_staff_weekly_expense_path(params[:staff_id],@staff_weekly_expense), :notice => 'Staff weekly expense was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @staff_weekly_expense.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /staff_weekly_expenses/1
  # DELETE /staff_weekly_expenses/1.xml
  def destroy
    @staff = Staff.find(params[:staff_id])
    @staff_weekly_expense = @staff.staff_weekly_expenses.find(params[:id])
    @staff_weekly_expense.destroy

    respond_to do |format|
      format.html { redirect_to(staff_weekly_expenses_url) }
      format.xml  { head :ok }
    end
  end
end
