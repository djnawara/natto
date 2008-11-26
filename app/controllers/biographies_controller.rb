class BiographiesController < CrudController
  # let's automatically load a user object from a params[:id] on these methods
  before_filter :find_object, :only => [:show, :edit, :update, :destroy, :media, :process_medium]
  skip_before_filter :login_required, :only => [:show]
  skip_before_filter :admin_required, :only => [:show]
  
  # GET /objects
  # GET /objects.xml
  def index
    @objects = @model_class.find(:all, :order => 'position')
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @objects }
      format.js   { render :html => @objects }
    end
  end
  
  def media
    @available_media = Medium.find(:all, :conditions => "parent_id IS NULL AND content_type LIKE '%image%'").reject {|medium| @object.media.include?(medium) }
  end
  
  def process_medium
    medium = Medium.find_by_id(params[:medium_id])
    if @object.media.include?(medium)
      @object.media.delete(medium)
      @object.save(false)
      create_change_log_entry(nil, nil, 'remove medium', "Removing medium #{medium.id}.")
    else
      @object.media << medium unless @object.media.include?(medium)
      @object.save(false)
      create_change_log_entry(nil, nil, 'add medium', "Adding medium #{medium.id}.")
    end
    respond_to do |format|
      format.html { redirect_to(media_biography_path(@object)) }
      format.xml  { head :ok }
    end
  end
  
  def update_positions
    params["biographies_tree"].each do |index,object|
      biography = Biography.find_by_id(object["id"])
      biography.position = index.to_i + 1
      biography.save
    end
    @objects = Biography.find(:all, :order => 'position')
    render :layout => false, :template => "biographies/index"
  end
end