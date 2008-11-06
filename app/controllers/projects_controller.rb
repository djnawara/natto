class ProjectsController < CrudController
  # let's automatically load a user object from a params[:id] on these methods
  before_filter :find_object, :only => [:show, :edit, :update, :destroy, :media, :process_medium]
  skip_before_filter :login_required, :only => [:show]
  skip_before_filter :admin_required, :only => [:show]

  def media
    @available_media = Medium.find(:all, :conditions => {:thumbnail => nil}).reject {|medium| @object.media.include?(medium) }
  end
  
  def index
    @objects = Project.find(:all, :order => :position)
  end
  
  def process_medium
    medium = Medium.find_by_id(params[:medium_id])
    if @object.media.include?(medium)
      @object.media.delete(medium)
      @object.save(false)
      create_change_log_entry(nil, nil, 'remove medium', "Removing the '#{medium.title}' medium.")
    else
      @object.media << medium unless @object.media.include?(medium)
      @object.save(false)
      create_change_log_entry(nil, nil, 'add medium', "Adding the '#{medium.title}' medium.")
    end
    respond_to do |format|
      format.html { redirect_to(media_project_path(@object)) }
      format.xml  { head :ok }
    end
  end
  
  # POST /objects
  # POST /objects.xml
  def create
    @object = Project.new(params[:project])
    @object.position = Project.count + 1
    Project.transaction do
      @object.save!
      create_change_log_entry
    end
    respond_to do |format|
      flash[:notice] = 'Project was successfully created.'
      format.html { redirect_to(@object) }
      format.xml  { render :xml => @object, :status => :created, :location => @object }
    end
  end
  
  def order
    @object = Page.find(:first, :conditions => {:advanced_path => 'project_positions_path'})
    @object = @object.nil? ? Page.admin_home : @object
    @page = @object
    @objects = Project.find(:all, :order => :position)
    respond_to do |format|
      format.html { render :layout => 'ajax' }
      format.xml  { head :ok }
    end
  end

  def update_positions
    params[:list].each_with_index do |id, position|
      Project.update(id, :position => position + 1)
    end
    @object = Page.find(:first, :conditions => {:advanced_path => 'project_positions_path'})
    @object = @object.nil? ? Page.admin_home : @object
    @page = @object
    @objects = Project.find(:all, :order => :position)
    render :layout => false, :action => 'order'
  end
end
