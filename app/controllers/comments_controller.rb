class CommentsController < CrudController
  protect_from_forgery :only => [:update, :destroy]
  
  before_filter :find_object, :only => [:show, :edit, :update, :destroy, :violation]  
  skip_before_filter :login_required, :only => [:show, :create, :violation]
  skip_before_filter :admin_required, :only => [:show, :create, :violation]

  # POST /objects
  # POST /objects.xml
  def create
    @object = Comment.new(params[:comment])
    Comment.transaction do
      @object.save!
      create_change_log_entry
    end
    respond_to do |format|
      flash[:notice] = 'Thanks for your comments.'
      format.html { redirect_to(@object.post) }
      format.xml  { render :xml => @object, :status => :created, :location => @object }
    end
  end

  def violation
    @object.violation_votes += 1
    @object.save
    respond_to do |format|
      @object.violation_votes > Natto.max_violation_votes
      flash[:notice] = 'The comment has been flagged; thanks for your concern.'
      format.html { redirect_to(@object.post) }
      format.xml  { render :xml => @object }
    end
  end
  
  # DELETE /objects/:id
  # DELETE /objects/:id.xml
  def destroy
    Comment.transaction do
      post = @object.post
      id = @object.id
      @object.destroy
      create_change_log_entry(id)
      respond_to do |format|
        format.html { redirect_to post }
        format.xml  { head :ok }
      end
    end
  end
end