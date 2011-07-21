class OutreachMailer < ActionMailer::Base
  def outreach_staff_mail(staff, outreach_event, current_user, update = nil)
    @staff = staff
    @current_user = current_user
    @outreach_event = outreach_event
    @update = update
    
    subject = "An outreach event(#{outreach_event.name}) is "
    if @update
      subject << "updated"
    else 
      subject << "created"
    end
    subject << " by #{current_user.full_name}"
    
    mail(:to => "#{staff.name} <#{staff.email}>", :subject => subject)
  end
end
