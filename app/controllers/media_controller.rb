require 'mini_magick'
require 'mimetype_fu'
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
      @object.content_type = File.mime_type?(@object.filename) if @object.content_type.blank? && !(@object.filename.nil? || @object.filename.blank?)
      if @object.save
        flash[:notice] = 'Medium was successfully created.'
        if @object.content_type.include?('image')
          redirect_to crop_thumb_path(@object)
        else
          redirect_to media_path
        end
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
  
  def crop_form
    @object = Medium.find(params[:id])
    respond_to do |format|
      format.html { render :layout => 'ajax', :template => 'media/crop_form' }
      format.xml  { render :xml => @object }
    end
  end
  
  def crop
    unless params[:commit].eql?("Skip")
      if medium = Medium.find_by_id(params[:medium_id])
        # the image to crop
        source_filename = File.join(RAILS_ROOT, "public", medium.public_filename(:croppable))
        # the image to overwrite
        target_filename = File.join(RAILS_ROOT, "public", medium.public_filename(params[:thumbnail]))
        # load the source image
        source_image = MiniMagick::Image.from_file(source_filename)
        # perform the crop
        source_image.crop("#{params[:width]}x#{params[:height]}+#{params[:offset_x]}+#{params[:offset_y]}!")
        # resize to appropriate size
        case(params[:thumbnail])
        when Medium::SMALL
          source_image.resize(Natto.small_image_size)
          version = medium.thumbnails.find_by_thumbnail(Medium::SMALL)
        when Medium::MEDIUM
          source_image.resize(Natto.medium_image_size)
          version = medium.thumbnails.find_by_thumbnail(Medium::MEDIUM)
        when Medium::LARGE
          source_image.resize(Natto.large_image_size)
          version = medium.thumbnails.find_by_thumbnail(Medium::LARGE)
        end
        # set the version's width and height
        version.width = source_image[:width]
        version.height = source_image[:height]
        version.save(false)
        # write to the target
        File.delete(target_filename) if File.exists?(target_filename)
        source_image.write(target_filename)
        File.chmod(0744, target_filename) # make sure the file is readable by others
        # done, redirect
        redirect_to image_version_path(medium, params[:thumbnail])
        return
      end
    end
    redirect_to media_path
  end
  
  def batch
    respond_to do |format|
      format.html
    end
  end
  
  def run_batch
    unless File.directory?(params[:directory])
      flash[:error] = "Not a directory."
      return
    end
    Dir.glob(File.join(params[:directory], '*.{jpg,jpeg,JPG,JPEG,png,PNG,tff,TFF,tiff,TIFF}')).each do |image_file|
      @object = Medium.new
      @object.uploaded_data = LocalFile.new(image_file)
      @object.medium_type = params[:batch][:medium_type]
      @object.parent_id = nil
      Medium.transaction do
        @object.save!
      end
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
      format.html { redirect_to image_version_path(@object, Medium::MEDIUM) }
      format.xml  { head :ok }
    end
  end
  
  def tiny_mce_image_list
    @objects = Medium.find(:all, :conditions => "content_type LIKE '%image%' AND parent_id IS NULL")
    respond_to do |format|
      format.html { render :layout => false, :template => 'media/tiny_mce_image_list' }
      format.js   { render :layout => false, :template => 'media/tiny_mce_image_list' }
    end
  end
  
  def tiny_mce_video_list
    @objects = Medium.find(:all, :conditions => "content_type LIKE '%video%' AND parent_id IS NULL")
    respond_to do |format|
      format.html { render :layout => false, :template => 'media/tiny_mce_media_list' }
      format.js   { render :layout => false, :template => 'media/tiny_mce_media_list' }
    end
  end
  
  def tiny_mce_audio_list
    @objects = Medium.find(:all, :conditions => "content_type LIKE '%audio%' AND parent_id IS NULL")
    respond_to do |format|
      format.html { render :layout => false, :template => 'media/tiny_mce_media_list' }
      format.js   { render :layout => false, :template => 'media/tiny_mce_media_list' }
    end
  end
  
  def tiny_mce_media_list
    @objects = Medium.find(:all, :conditions => "content_type NOT LIKE '%image%' AND parent_id IS NULL")
    respond_to do |format|
      format.html { render :layout => false, :template => 'media/tiny_mce_media_list' }
      format.js   { render :layout => false, :template => 'media/tiny_mce_media_list' }
    end
  end
end