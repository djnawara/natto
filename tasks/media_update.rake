namespace :media do
  desc "Updates all thumbnails for media"
  task(:update => :environment) do
    Medium.find(:all, :conditions => "parent_id IS NULL AND content_type LIKE '%image%'").each do |medium|
      #destroy the thumbnails first
      medium.thumbnails.each { |thumbnail| thumbnail.destroy } if medium.thumbnailable?
      #then recreate the thumbnails
      medium.attachment_options[:thumbnails].each { |suffix, size| medium.create_or_update_thumbnail(medium.create_temp_file, suffix, *size) }
    end
  end
end
