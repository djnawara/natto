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
      @object.uploaded_data = LocalFile.new(params[:medium][:filename]) if (@object.uploaded_data.nil? || @object.uploaded_data.empty?) unless params[:medium][:filename].blank?
      @object.parent_id = nil
      # set the mime type via the mimetype-fu plugin, as needed
      @object.content_type = File.mime_type?(@object.filename) if @object.content_type.blank?
      if @object.save
        flash[:notice] = 'Medium was successfully created.'
        redirect_to media_path
      else
        render :action => "new", :template => 'media/form'
      end
    rescue ActiveRecord::RecordInvalid => invalid
      invalid.record.errors.each do |error|
        logger.error("RECORD ERROR > #{error}")
      end
      redirect_to :action => "new", :template => 'media/form'
    rescue Exception => e
      logger.warn(e.message)
      flash[:error] = e.message
      redirect_to :action => "new", :template => 'media/form'
    end
  end
  
  def batch
    Dir.glob(File.join(params[:directory], '*.{jpg,jpeg,JPG,JPEG,png,PNG,tff,TFF,tiff,TIFF}')).each do |image_file|
      @object = Medium.new
      @object.uploaded_data = LocalFile.new(image_file)
      @object.parent_id = nil
      @object.save
    end
    flash[:notice] = "Directory batch imported."
    redirect_to media_path
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