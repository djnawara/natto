class ProjectsController < CrudController
  # let's automatically load a user object from a params[:id] on these methods
  before_filter :find_object, :only => [:show, :edit, :update, :destroy, :media, :process_medium]
  skip_before_filter :login_required, :only => [:show]
  skip_before_filter :admin_required, :only => [:show]

  def media
    @available_media = Medium.find(:all, :conditions => {:thumbnail => nil}).reject {|medium| @object.media.include?(medium) }
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
end
