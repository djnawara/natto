class BackupsController < ApplicationController
  before_filter :set_backup,              :only => [:new, :restore, :destroy, :show, :download]
  before_filter :set_comments,            :only => [:new, :restore, :destroy, :show]
  before_filter :create_change_log_entry, :only => [:new, :restore, :destroy, :show]
  
  def index
    # grab all yaml/archive files from the backup directory
    @objects = Dir.entries(RAILS_ROOT + '/backups/').reject { |file|
      !Backup.name_well_formed?(file)
    }.sort.collect {
      |file| Backup.new(file)
    }
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @objects }
    end
  end
  
  def new
    # get a handle on all the yaml files in the backup directory
    @backup.create
    flash[:notice] = 'Backup created.'
    redirect_to(:action => 'index')
  end
  
  def restore
    @backup.restore
    flash[:notice] = 'Backup restored.'
    redirect_to(:action => 'index')
  end
  
  def destroy
    @backup.destroy
    flash[:notice] = 'Backup removed.'
    redirect_to(:action => 'index')
  end
  
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @backup }
    end
  end
  
  def download
    send_file(@backup.full_filename)
  end
  
  # Set a backup object based on what we have in params.
  def set_backup
    if params[:id] && !params[:id].blank?
      @backup = Backup.new(nil, current_user.id)
      @backup.id_from_epoch(params[:id])
    else
      @backup = Backup.new(nil, current_user.id)
    end
  end
  private :set_backup
  
  def set_comments
    @backup.comments = ''
    @backup.comments = params[:change_log][:comments] if params[:change_log] && params[:change_log][:comments]
  end
  private :set_comments
  
  # Create and save a change_log for the backup action.
  def create_change_log_entry
    @change_log = @backup.create_change_log_entry(params[:action])
    @change_log.save!
  end
  private :create_change_log_entry
  
  # Handle failed validations when saving.
  rescue_from ActiveRecord::RecordInvalid do |exception|
    flash.discard # since we are doing a render, we can discard the flash after this action
    respond_to do |format|  # render the action and show the errors
      format.html { render :template => 'shared/get_comments' }
      format.xml  { render :xml => @object.errors, :status => :unprocessable_entity }
    end
  end
end