class CrudController < ApplicationController
  # determine the model class for our find_object filter
  before_filter :set_model
  # let's automatically load a user object from a params[:id] on these methods
  before_filter :find_object, :only => [:show, :edit, :update, :destroy]  
  
  # create a change_log entry
  def create_change_log_entry(object_id = nil, user_id = nil, action = nil, comments = nil)
    action = params[:action] if action.nil?
    comments = params[:change_log][:comments] unless !comments.nil? || (params[:change_log].nil? || params[:change_log][:comments].blank?)
    object_id = @object.id if object_id.nil?
    user_id = current_user.id if logged_in?
    if (comments.nil?)
      case action
      when 'create'
        comments = 'Initial creation of ' + params[:controller].singularize + '.'
      when 'update'
        comments = 'Updating information for ' + params[:controller].singularize + '.'
      else
        # Default to just listing the controller name and action
        comments = "#{params[:controller]} #{params[:action]}"
      end
    end
    @change_log = ChangeLog.new({:object_id => object_id, :user_id => user_id, :action => action, :comments => comments, :performed_at => Time.now.to_s(:db), :object_class => params[:controller].singularize})
    @change_log.save!
  end
  
  # Reflect on the controller to get the model constant out of the Kernel object.
  def set_model
    @model_class = Kernel.const_get(self.class.name.gsub(/Controller$/, '').singularize)
  end
  
  # Use the discovered model to find the object instance on which to operate.
  def find_object
    @object = @model_class.find_by_id(params[:id].to_i)
  end
  
  # GET /objects
  # GET /objects.xml
  def index
    @objects = @model_class.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @objects }
      format.js   { render :html => @objects }
    end
  end
  
  # GET /objects/1
  # GET /objects/1.xml
  def show
    respond_to do |format|
      format.html { render :template => views_directory + '/show' }
      format.xml  { render :xml => @object }
    end
  end
  
  # GET /objects/new
  # GET /objects/new.xml
  def new
    @object = @model_class.new
    respond_to do |format|
      format.html { render :template => views_directory + '/form' }
      format.xml  { render :xml => @object }
    end
  end

  # GET /objects/1/edit
  def edit
    respond_to do |format|
      format.html { render :template => views_directory + '/form' }
      format.xml  { render :xml => @object }
    end
  end

  # POST /objects
  # POST /objects.xml
  def create
    @object = @model_class.new(params[@model_class.name.tableize.singularize.to_sym])
    @model_class.transaction do
      @object.save!
      create_change_log_entry
    end
    respond_to do |format|
      flash[:notice] = @model_class.name.humanize + ' was successfully created.'
      format.html { redirect_to(@object) }
      format.xml  { render :xml => @object, :status => :created, :location => @object }
    end
  end
  
  # DELETE /objects/:id
  # DELETE /objects/:id.xml
  def destroy
    @model_class.transaction do
      id = @object.id
      @object.destroy
      create_change_log_entry(id)
    end
    respond_to do |format|
      format.html { redirect_to(:action => 'index') }
      format.xml  { head :ok }
    end
  end
  
  # PUT /objects/1
  # PUT /objects/1.xml
  def update
    @model_class.transaction do
      @object.update_attributes!(params[@object.class.name.tableize.singularize.to_sym])
      create_change_log_entry
    end
    respond_to do |format|
      flash[:notice] = @model_class.name + ' was successfully updated.'
      format.html { redirect_to(@object) }
      format.xml  { head :ok }
    end
  end
  
  def views_directory
    @model_class.name.tableize.pluralize
  end
  
  # Handle failed validations when saving.
  rescue_from ActiveRecord::RecordInvalid do |exception|
    case params[:action]  # determine the proper page to render for the action
    when 'new', 'edit', 'create', 'update'
      flash[:error] = "<h2>Change log comments required</h2>Please enter comments for the change log." if @change_log && !@change_log.valid?
      view = @model_class.name.tableize.pluralize + '/' + 'form' # re-render the form
    when 'destroy', 'purge'
      view = 'shared/get_comments' # force comments for the change log
    else
      view = 'shared/get_comments' # force comments for the change log
    end
    flash.discard # since we are doing a render, we can discard the flash after this action
    respond_to do |format|  # render the action and show the errors
      format.html { render :template => view }
      format.xml  { render :xml => @object.errors, :status => :unprocessable_entity }
    end
  end
end
