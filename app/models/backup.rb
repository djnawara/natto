class Backup
  attr_accessor :comments, :filename, :user_id, :date, :change_log, :extracted_directory, :id
  
  TIMESTAMP_MATCH             = /(^[\d]{8})-([\d]{6})/
  EXTENSION_MATCH             = /\.tar\.gz$|\.tar\.bz$|\.zip$|\.yml$/
  FILENAME_EXTENSION_MATCH    = /\.tar\.gz$/
  FILENAME_EXTENSION          = '.tar.gz'
  BACKUPS_FOLDER              = 'backups'
  
  # Create a new backup object from a filename, or by
  # using the current time to generate a new filename.
  def initialize(filename = nil, user_id = nil)
    # Always filename first, so we can extract the timestamp
    set_name(filename)
    # Always timestamp second, so we can find changelogs
    set_date
    # we get the id from the date
    set_id
    # Get the changelog
    set_change_log_from_create
    # Now we can get the user id, potentially from the changelog
    self.user_id = user_id.nil? ? get_user_id_from_change_log : user_id
    # You can get this as soon as we have a filename
    set_extracted_directory
  end
  
  # Export fixtures, and archive them into a "backup."
  def create
    `rake db:fixtures:export RAILS_ENV=#{ENV['RAILS_ENV']}`
    Dir.chdir("#{RAILS_ROOT}/#{BACKUPS_FOLDER}")
    `tar cvzf #{self.filename} *.yml`
    `rm *.yml`
  end
  
  # Load an archive's yaml into the db.
  def restore
    `tar xvzf #{self.filename}`                             # extract the file
    Dir.chdir("#{RAILS_ROOT}/#{BACKUPS_FOLDER}")            # move to the backups folder
    `mv #{extracted_directory}/*.yml ./`                    # move the yml to the backups root
    `rake db:fixtures:import RAILS_ENV=#{ENV['RAILS_ENV']}` # import the yaml files into the DB
    `rmdir #{self.extracted_directory}`                     # clean up artifacts of the process
    `rm *.yml`                                              # ...
  end
  
  # Remove a backup archive from the system.
  def destroy
    File.delete("#{RAILS_ROOT}/#{BACKUPS_FOLDER}/#{self.filename}")
  end
  
  # Creates a change_log entry for our backup
  def create_change_log_entry(action)
    self.comments = "Restoring #{self.filename}: " + self.comments if action.eql?('restore') && !self.comments.blank?
    # note that the filename timestamp is used to generate an id as seconds since epoch
    ChangeLog.new({:object_class => self.class.name.downcase,
                                 :object_id => self.id,
                                 :user_id => self.user_id,
                                 :action => action,
                                 :performed_at => Time.now.to_s(:db),
                                 :comments => self.comments})
  end
  
  # Set the date for this backup, based on the timestamp
  # in its filename.
  def set_date
    return if self.filename.nil? || self.date
    match = self.filename.match(TIMESTAMP_MATCH)
    date = match[1]
    time = match[2]
    # convert the timestamp in the filname to a Ruby Time object
    self.date = Time.parse(date + ' ' + time)
  end
  private :set_date
  
  # Calculate the name of the extracted directory.
  def set_extracted_directory
    self.extracted_directory = self.filename.gsub(FILENAME_EXTENSION_MATCH, '')
  end
  
  # Create a file name from the current time.
  # self.filename = ( || !self.class.name_well_formed?(filename)) ? create_name : filename

  def set_name(filename = nil, time = nil)
    time = self.date || Time.now if time.nil?
    if filename.nil?
      self.filename = time.strftime('%Y%m%d-%H%M%S') + FILENAME_EXTENSION
    else
      self.filename = filename
    end
  end
  
  # Grab comments from the change log for this backups "new" event.
  def set_change_log_from_create
    # find comments for the creation of this backup
    self.change_log = ChangeLog.find(:first, :conditions => {:object_class => self.class.name.downcase, :object_id => self.id, :action => 'new'})
  end
  private :set_change_log_from_create
  
  def get_user_id_from_change_log
    self.change_log.nil? ? 'unknown' : self.change_log.user_id.to_s
  end
  private :get_user_id_from_change_log
  
  def self.name_well_formed?(filename)
    !filename.match(TIMESTAMP_MATCH).nil? && !filename.match(EXTENSION_MATCH).nil?
  end
  
  # Parse out the periods in the filename, or the routes
  # seem to get confused (:format issue, I assume).
  def filename_for_url
    self.filename.gsub(/\./, '_')
  end
  
  def full_filename
    "#{RAILS_ROOT}/#{BACKUPS_FOLDER}/#{self.filename}"
  end
  
  def create_comments
    self.change_log.nil? ? 'Unavailable' : self.change_log.comments
  end
  
  # Returns a fake id for the object.
  def set_id
    self.id = self.date.to_i
  end
  
  def id_from_epoch(time_since_epoch)
    self.date = Time.at(time_since_epoch.to_i)
    set_id
    set_name
  end
  
  # Return a filename to its proper state, after retrieving
  # it from the params hash.
  def self.url_decode(filename)
    filename.gsub(/_/, '.')
  end
end