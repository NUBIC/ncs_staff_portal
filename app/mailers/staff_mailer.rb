class StaffMailer < ActionMailer::Base
  def staff_reminder_mail(staff)
    @staff = staff

    mail(:to => "#{staff.name} <#{staff.email}>", :subject => "NCS Navigator Ops: No task entry for week starting from " << Date.today.monday.to_s)
  end
end
