class MediaController < CrudController
  # GET /objects
  # GET /objects.xml
  def index
    @objects = Medium.find(:all, :conditions => {:thumbnail => nil})
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @objects }
      format.js   { render :html => @objects }
    end
  end

  def create
    begin
      @object = Medium.new(params[:medium])
      @object.parent_id = nil
      if @object.save
        flash[:notice] = 'Medium was successfully created.'
        redirect_to @object
      else
        render :action => :new
      end
    rescue ActiveRecord::RecordInvalid => invalid
      invalid.record.errors.each do |error|
        logger.error("RECORD ERROR > #{error}")
      end
      redirect_to :action => "new"
    rescue Exception => e
      logger.warn(e.msg)
      redirect_to :action => "new"
    end
  end
  
  # PUT /media/1
  # PUT /media/1.xml
  def update
    Medium.transaction do
      @object.update_attributes!(params[:medium])
      create_change_log_entry
    end
    respond_to do |format|
      flash[:notice] = 'Medium was successfully updated.'
      format.html { redirect_to(@object) }
      format.xml  { head :ok }
    end
  end
  
end