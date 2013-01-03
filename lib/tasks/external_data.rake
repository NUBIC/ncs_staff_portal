require 'csv'
namespace :import do
  desc 'Import Expenses'
  task :expenses, [:file] => [:environment] do |t, args|
    @input_io = args[:file]
    fail 'Please specify the path to the expenses csv' unless @input_io
    @errors = []

    import_data("Expenses")
  end

  desc 'Import Outreach'
  task :outreach, [:file] => [:environment] do |t, args|
    @input_io = args[:file]
    fail 'Please specify the path to the outreach csv' unless @input_io
    @errors = []

    import_data("Outreach")
  end
  
  def csv
    @csv ||= CSV.read(@input_io, :headers => true, :header_converters => :symbol)
  end

  def import_data(import_type)
    csv.each_with_index do |row, i|
      next if row.header_row?
      begin
        if import_type == "Expenses"
          import_expenses(row, i)
        elsif import_type == "Outreach"
          import_outreach(row, i)
        end
      rescue => e
        add_error(i, "#{e.class}: #{e}.\n  #{e.backtrace.join("\n  ")}")
      end

      print_status row_progress_message(i)
    end
    print_status "\nRow importing complete.\n"

    @errors.empty?
  end

  def errors
    @errors.collect(&:to_s)
  end

  def import_expenses(row, i)
    if staff = find_staff_or_add_error(row[:staff_id], i)
      task_date = row[:date]
      rate = row[:rate]
      hours = row[:hours]
      expenses = row[:expenses]
      miles = row[:miles]
      task_date_date = Date.parse("#{task_date}")
      week_start_date = task_date_date.beginning_of_week
      task_type = row[:task_type]
      other = row[:other]
      staff_weekly_expense = StaffWeeklyExpense.find_or_create_by_week_start_date_and_staff_id(week_start_date, staff.id, :rate => rate)
      if row[:management] == 'yes'
        task = create_task(ManagementTask, task_date_date, task_type, other, "STUDY_MNGMNT_TSK_TYPE_CL1", i)
      elsif row[:data_collection] == 'yes'
        task = create_task(DataCollectionTask, task_date_date, task_type, other, "STUDY_DATA_CLLCTN_TSK_TYPE_CL1", i)
      elsif row[:weekly] == 'yes'
        staff_weekly_expense.comment = "Vacation Time"
        save_or_report_problems(staff_weekly_expense, i)        
      end
      
      if task
        task.hours = hours
        task.expenses = expenses
        task.miles = miles
        task.staff_weekly_expense = staff_weekly_expense
        save_or_report_problems(task, i)
      end
    end
  end

  def import_outreach(row, i)
    staff_ids = row[:staff].split(';')
    staff_id1 = staff_ids[0]
    staff_id2 = staff_ids[1] if staff_ids.size > 1
    if staff1 = find_staff_or_add_error(staff_id1, i)
      event_date = row[:date]
      event_name =  row[:name]
      ssu = row[:ssu]
      mode = row[:mode]
      type = row[:type]
      type_other = row[:type_other]
      targets = row[:target].split(';')
      letters_quantity = row[:materials]
      attendees_quantity = row[:attendees]
      cost = row[:cost]
      tailored = row[:tailored]
      evaluation_result = row[:evaluation_result]
      no_of_staff = row[:no_of_staff]
      evaluations = row[:evaluations]

      outreach = OutreachEvent.create(:import => "true", :mode_code => mode, :outreach_type_code => type, :outreach_type_other => type_other, 
                                      :event_date => event_date, :name => event_name, :letters_quantity => letters_quantity,
                                      :attendees_quantity => attendees_quantity, :cost => cost, :tailored_code => tailored,
                                      :evaluation_result_code => evaluation_result, :no_of_staff => no_of_staff)
      if ssu == 'All'
        NcsSsu.all.each do |ncs_ssu|
          creat_ssu(ncs_ssu, outreach, i)
        end
      else
        if ncs_ssu = NcsSsu.find_by_ssu_name(ssu)
          creat_ssu(ncs_ssu, outreach, i)
        end
      end

      save_outreach_staff_member(staff1, outreach, i)
      if staff_id2 && staff2 = find_staff_or_add_error(staff_id2, i)
        save_outreach_staff_member(staff2, outreach, i)
      end

      outreach_evaluation = OutreachEvaluation.new(:evaluation_code => evaluations, :outreach_event => outreach)
      save_or_report_problems(outreach_evaluation,i)

      creat_outreach_target(targets[0], outreach, i)
      creat_outreach_target(targets[1], outreach, i) if targets.size > 1
    end
  end

  def creat_ssu(ncs_ssu, outreach, i)
    outreach_segment = OutreachSegment.new(:ncs_ssu => ncs_ssu, :outreach_event => outreach)
    save_or_report_problems(outreach_segment, i)
  end
  private :creat_ssu

  def creat_outreach_target(target, outreach, i)
    outreach_target = OutreachTarget.new(:target_code => target, :outreach_event => outreach)
    save_or_report_problems(outreach_target, i)
  end
  private :creat_outreach_target

  def save_outreach_staff_member(staff, outreach, i)
    outreach_staff_member = OutreachStaffMember.new(:staff => staff, :outreach_event => outreach)
    save_or_report_problems(outreach_staff_member, i)
  end
  private :save_outreach_staff_member

  def add_error(row_index, message)
    @errors << Error.new(row_index + 1, message)
  end

  def save_or_report_problems(instance, row_index)
    if instance.save
      true
    else
      instance.errors.full_messages.each do |message|
        add_error(row_index, "Invalid #{instance.class}: #{message}.")
      end
    end
  end

  def row_progress_message(row_index)
    msg = "\r#{row_index + 1}/#{csv.size} processed"
    unless @errors.empty?
      msg << " | #{@errors.size} error#{'s' if @errors.size != 1}"
    end
    msg
  end

  def print_status(message)
    $stderr.print message unless @quiet
  end

  class Error < Struct.new(:row_number, :message)
    def to_s
      "Error on row #{row_number}. #{message}"
    end
  end

  def find_staff_or_add_error(staff_id, row_index)
    staff = Staff.where(:staff_id => staff_id).first
    unless staff
      add_error(row_index, "Unknown staff #{staff_id.inspect}.")
      return nil
    end
    staff
  end
  private :find_staff_or_add_error

  def create_task(task_class, task_date, task_type, other, list, row_index)
    if task_type_code = find_task_type_or_add_error(task_type, list, row_index)
      task = task_class.new(:task_type_code => task_type_code, :task_date => task_date)
      if task_type_code.local_code == -5
        task.task_type_other = other
      end
      task
    end
  end

  def find_task_type_or_add_error(task_type, list, row_index)
    task_type_code = NcsCode.find(:first, :conditions=>['LOWER(display_text) = ? and list_name = ? ', task_type.downcase, list])
    unless task_type_code
      add_error(row_index, "Unknown task_type #{task_type}.")
      return nil
    end
    task_type_code
  end
  private :find_task_type_or_add_error

end