namespace :media do
  desc "Updates all thumbnails for media"
  task(:update => :environment) do
    # get a handle on some folders
    media_base = File.join(RAILS_ROOT, Medium.attachment_options[:path_prefix])
    # loop through all media
    Medium.find(:all, :conditions => "parent_id IS NULL").each do |medium|
      # destroy the thumbnails first
      medium.thumbnails.each { |thumbnail| thumbnail.destroy } if medium.thumbnailable?
      # first, pad the id and make sure we have 8 characters
      medium_id = medium.id.to_s.rjust(8, '0')
      # make sure its partition exists
      partition = File.join(media_base, medium_id[0,4], medium_id[4,4])
      File.makedirs(partition) unless File.exists?(partition)
      # check for a file in the base folder
      old_storage_file = File.join(media_base, medium.filename)
      if File.exists?(old_storage_file)
        # move the main file to its partition
        File.copy(old_storage_file, File.join(partition, medium.filename))
        # remove the old copy
        File.delete(old_storage_file)
      end
      # recreate the thumbnails
      medium.attachment_options[:thumbnails].each { |suffix, size| medium.create_or_update_thumbnail(medium.create_temp_file, suffix, *size) } if medium.thumbnailable?
    end
  end
end
