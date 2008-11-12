class PostsController < CrudController
  before_filter :find_object, :only => [:show, :edit, :update, :destroy, :purge, :undelete, :approve, :publish, :unpublish]
  skip_before_filter :login_required, :only => [:show, :feeds]
  skip_before_filter :admin_required, :only => [:show, :feeds]
  
  # GET /objects
  # GET /objects.xml
  def index
    @objects = Post.find(:all, :order => 'created_at DESC')
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @objects }
      format.js   { render :html => @objects }
    end
  end
  
  # GET /posts/new
  # GET /posts/new.xml
  def new
    @object = Post.new
    @object.page_id = params[:page_id] unless params[:page_id].nil? || params[:page_id].blank?
    respond_to do |format|
      format.html { render :template => "posts/form" }
      format.xml  { render :xml => @object }
    end
  end

  # POST /objects
  # POST /objects.xml
  def create
    @object = Post.new(params[:post])
    Post.transaction do
      @object.save!
      create_change_log_entry
    end
    flash[:notice] = 'The post was successful.'
    respond_to do |format|
      format.html { @object.page.nil? ? redirect_to(@object) : redirect_to(@object.page) }
      format.xml  { render :xml => @object, :status => :created, :location => @object }
    end
  end
  
  # PUT /objects/1
  # PUT /objects/1.xml
  def update
    Post.transaction do
      @object.update_attributes!(params[:post])
      create_change_log_entry
    end
    respond_to do |format|
      flash[:notice] = 'Post successfully updated.'
      format.html { @object.page.nil? ? redirect_to(@object) : redirect_to(@object.page) }
      format.xml  { head :ok }
    end
  end

  # DELETE /pages/:id
  # DELETE /pages/:id.xml
  #
  # Perform non-destructive delete.  To permanently destroy the object,
  # see purge.
  def destroy
    Post.transaction do
      @object.delete!
      create_change_log_entry
    end
    respond_to do |format|
      format.html { redirect_to(posts_url) }
      format.xml  { head :ok }
    end
  end

  # DELETE /pages/:id/purge
  # DELETE /pages/:id/purge.xml
  def purge
    Post.transaction do
      # store these for later use
      id = @object.id
      page = @object.page
      # remote the object
      @object.destroy
      # add a change log entry
      create_change_log_entry(id)
      respond_to do |format|
        format.html { page.nil? ? redirect_to(posts_path) : redirect_to(page) }
        format.html { redirect_to(posts_path) }
        format.xml  { head :ok }
      end
    end
  end
  
  def undelete
    Post.transaction do
      @object.undelete!
      create_change_log_entry
    end
    respond_to do |format|
      format.html { redirect_to(posts_url) }
      format.xml  { head :ok }
    end
  end
  
  def publish
    Post.transaction do
      @object.publish!
      create_change_log_entry
    end
    respond_to do |format|
      format.html { redirect_to(posts_url) }
      format.xml  { head :ok }
    end
  end
  
  def unpublish
    Post.transaction do
      @object.unpublish!
      create_change_log_entry
    end
    respond_to do |format|
      format.html { redirect_to(posts_url) }
      format.xml  { head :ok }
    end
  end
  
  def approve
    Post.transaction do
      @object.approve!
      create_change_log_entry
    end
    respond_to do |format|
      format.html { redirect_to(posts_url) }
      format.xml  { head :ok }
    end
  end
  
  def show
    @comment = Comment.new
    @comment.post_id  = @object.id
    super
  end
  
  def feeds
    @objects = Post.find_in_state(:all, :published, :order => 'published_at DESC')
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
    respond_to do |format|
      format.rss  {render :layout => false, :template => 'shared/rss.xml.haml'}
      format.atom {render :layout => false, :template => 'shared/atom.xml.haml'}
    end
  end
end