class WidgetsController < CrudController
  # GET /widgets/new
  # GET /widgets/new.xml
  def new
    @object = Widget.new
    @object.parent_id   = params[:parent_id]    unless params[:parent_id].nil?    || params[:parent_id].blank?
    @object.parent_type = params[:parent_type]  unless params[:parent_type].nil?  || params[:parent_type].blank?
    respond_to do |format|
      format.html { render :template => "widgets/form" }
      format.xml  { render :xml => @object }
    end
  end

  # POST /objects
  # POST /objects.xml
  def create
    @object = Widget.new(params[:widget])
    Widget.transaction do
      @object.save!
      create_change_log_entry
    end
    respond_to do |format|
      flash[:notice] = 'The post was successful.'
      format.html do
        if @object.parent_id.nil? || @object.parent_type.nil?
          redirect_to(@object)
        else
          redirect_to(Kernel.const_get(@object.parent_type).find_by_id(@object.parent_id))
        end
      end
      format.xml  { render :xml => @object, :status => :created, :location => @object }
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
      format.html do
        if @object.parent_id.nil? || @object.parent_type.nil?
          redirect_to(@object)
        else
          redirect_to(Kernel.const_get(@object.parent_type).find_by_id(@object.parent_id))
        end
      end
      format.xml  { head :ok }
    end
  end
  
  # DELETE /objects/:id
  # DELETE /objects/:id.xml
  def destroy
    Widget.transaction do
      # store these for later use
      id = @object.id
      parent_id   = @object.parent_id
      parent_type = @object.parent_type
      # remote the object
      @object.destroy
      # add a change log entry
      create_change_log_entry(id)
    end
    respond_to do |format|
      format.html do
        if parent_id.nil? || parent_type.nil?
          redirect_to(widgets_path)
        else
          redirect_to(Kernel.const_get(parent_type).find_by_id(parent_id))
        end
      end
      format.html { redirect_to(widgets_path) }
      format.xml  { head :ok }
    end
  end
end