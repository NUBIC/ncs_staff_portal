class StaffLanguagesController < SecuredController
  # GET /staff_languages
  # GET /staff_languages.xml
  def index
    @staff_languages = StaffLanguage.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @staff_languages }
    end
  end

  # GET /staff_languages/1
  # GET /staff_languages/1.xml
  def show
    @staff_language = StaffLanguage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @staff_language }
    end
  end

  # GET /staff_languages/new
  # GET /staff_languages/new.xml
  def new
    @staff_language = StaffLanguage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @staff_language }
    end
  end

  # GET /staff_languages/1/edit
  def edit
    @staff_language = StaffLanguage.find(params[:id])
  end

  # POST /staff_languages
  # POST /staff_languages.xml
  def create
    @staff_language = StaffLanguage.new(params[:staff_language])

    respond_to do |format|
      if @staff_language.save
        format.html { redirect_to(@staff_language, :notice => 'Staff language was successfully created.') }
        format.xml  { render :xml => @staff_language, :status => :created, :location => @staff_language }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @staff_language.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /staff_languages/1
  # PUT /staff_languages/1.xml
  def update
    @staff_language = StaffLanguage.find(params[:id])

    respond_to do |format|
      if @staff_language.update_attributes(params[:staff_language])
        format.html { redirect_to(@staff_language, :notice => 'Staff language was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @staff_language.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /staff_languages/1
  # DELETE /staff_languages/1.xml
  def destroy
    @staff_language = StaffLanguage.find(params[:id])
    @staff_language.destroy

    respond_to do |format|
      format.html { redirect_to(staff_languages_url) }
      format.xml  { head :ok }
    end
  end
end
