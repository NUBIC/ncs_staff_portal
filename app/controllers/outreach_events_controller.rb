class OutreachEventsController < SecuredController
  set_tab :outreach_events
  # GET /outreach_events
  # GET /outreach_events.xml
  def index
    @outreach_events = OutreachEvent.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @outreach_events }
    end
  end

  # GET /outreach_events/1
  # GET /outreach_events/1.xml
  def show
    @outreach_event = OutreachEvent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @outreach_event }
    end
  end

  # GET /outreach_events/new
  # GET /outreach_events/new.xml
  def new
    @outreach_event = OutreachEvent.new
    @outreach_event.outreach_staff_members.build
    @outreach_event.outreach_ssus.build
    @outreach_event.outreach_evaluations.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @outreach_event }
    end
  end

  # GET /outreach_events/1/edit
  def edit
    @outreach_event = OutreachEvent.find(params[:id])
  end

  # POST /outreach_events
  # POST /outreach_events.xml
  def create
    @outreach_event = OutreachEvent.new(params[:outreach_event])

    respond_to do |format|
      if @outreach_event.save
        format.html { redirect_to(@outreach_event, :notice => 'Outreach event was successfully created.') }
        format.xml  { render :xml => @outreach_event, :status => :created, :location => @outreach_event }
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
        format.html { redirect_to(@outreach_event, :notice => 'Outreach event was successfully updated.') }
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
