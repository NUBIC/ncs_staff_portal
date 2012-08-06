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

  # PUT /staff_weekly_expenses/1
  # PUT /staff_weekly_expenses/1.xml
  def update
    @staff_weekly_expense = StaffWeeklyExpense.find(params[:id])
    @staff_weekly_expense.comment = params[:comment]
    @staff_weekly_expense.save!

    respond_to do |format|
      format.json { 
        if request.xhr?
          render :json => @staff_weekly_expense.comment
        else
          render :json => @staff_weekly_expense
        end
      }
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
