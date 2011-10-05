class OutreachEventsController < SecuredController
  permit Role::OUTREACH_STAFF
  set_tab :outreach_events
  add_breadcrumb "Outreach Activities", :outreach_events_path, :only => %w(new edit) 
  # GET /outreach_events
  # GET /outreach_events.xml
  def index
    params[:page] ||= 1
    # @outreach_events = OutreachEvent.all.sort_by(&:event_date).reverse.paginate(:page => params[:page], :per_page => 20)
    @outreach_events =  OutreachEvent.search_for(params[:search]).all.sort_by(&:event_date).reverse.paginate(:page => params[:page], :per_page => 20)
    @can_delete = false
    if permit?(Role::STAFF_SUPERVISOR)
      @can_delete = true
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @outreach_events }
    end
  end

  # GET /outreach_events/new
  # GET /outreach_events/new.xml
  def new
    @outreach_event = OutreachEvent.new
    @outreach_event.outreach_staff_members.build
    @outreach_event.outreach_evaluations.build
    @outreach_event.outreach_targets.build
    add_breadcrumb "New outreach event", new_outreach_event_path
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @outreach_event }
    end
  end

  # GET /outreach_events/1/edit
  def edit
    @outreach_event = OutreachEvent.find(params[:id])
    add_breadcrumb "Edit outreach event", edit_outreach_event_path(@outreach_event)
  end

  # POST /outreach_events
  # POST /outreach_events.xml
  def create
    @outreach_event = OutreachEvent.new(params[:outreach_event])
    @outreach_event.created_by = @current_staff.id
    respond_to do |format|
      if @outreach_event.save
        @outreach_event.outreach_staff_members.each do |s|
          OutreachMailer.outreach_staff_mail(s.staff, @outreach_event, current_user).deliver unless current_user.username == s.staff.username
        end
        format.html { redirect_to(outreach_events_path, :notice => 'Outreach event was successfully created.') }
        format.xml  { render :xml => outreach_events_path, :status => :created, :location => @outreach_event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @outreach_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /outreach_events/1
  # PUT /outreach_events/1.xml
  def update
    @outreach_event = OutreachEvent.find(params[:id])
    respond_to do |format|
      if @outreach_event.update_attributes(params[:outreach_event])
        @outreach_event.outreach_staff_members.each do |s|
          OutreachMailer.outreach_staff_mail(s.staff, @outreach_event, current_user, "true").deliver unless current_user.username == s.staff.username
        end
        format.html { redirect_to(outreach_events_path, :notice => 'Outreach event was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @outreach_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /outreach_events/1
  # DELETE /outreach_events/1.xml
  def destroy
    @outreach_event = OutreachEvent.find(params[:id])
    @outreach_event.destroy

    respond_to do |format|
      format.html { redirect_to(outreach_events_url) }
      format.xml  { head :ok }
    end
  end
end
