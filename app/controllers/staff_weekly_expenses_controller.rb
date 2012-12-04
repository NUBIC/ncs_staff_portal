class StaffWeeklyExpensesController < StaffAuthorizedController
  set_tab :time_and_expenses

  with_options(:except => :index) do |c|
    c.before_filter :load_staff
    c.before_filter :assert_staff
    c.before_filter :check_requested_staff_visibility
  end

  before_filter :check_staff_access, :only => %w(by_staff)
  # GET /staff_weekly_expenses
  # GET /staff_weekly_expenses.xml
  def index
    params[:page] ||= 1
    @q = StaffWeeklyExpense.search(params[:q])
    @staff_weekly_expenses = (StaffWeeklyExpense.visible_expenses(@current_staff.visible_employees.map(&:id)) & @q.result(:distinct => true)).sort_by(&:week_start_date).reverse.paginate(:page => params[:page], :per_page => 20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @staff_weekly_expenses }
    end
  end

  # GET /staff_weekly_expenses/by_staff?staff_id=
  def by_staff
    params[:page] ||= 1
    @q = StaffWeeklyExpense.search(params[:q])
    @staff_weekly_expenses = (@staff.staff_weekly_expenses & @q.result(:distinct => true)).sort_by(&:week_start_date).reverse.paginate(:page => params[:page], :per_page => 20)
    respond_to do |format|
      format.html { render :layout => tasks_layout }
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
    @staff_weekly_expense = StaffWeeklyExpense.find(params[:id])
    @staff_weekly_expense.destroy

    respond_to do |format|
      format.html {
      if params[:staff_id]
        redirect_to(by_staff_staff_weekly_expenses_url(:staff_id => params[:staff_id]))
      else
        redirect_to(staff_weekly_expenses_url)
      end
      }
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
      @staff = Staff.find(params[:staff_id])
      same_as_current_user(@staff) ? "layouts/application" : "layouts/staff_information"
    end
end
