class ChangeLog < ActiveRecord::Base
  validates_presence_of :comments
  validates_length_of :comments, :within => 10..1000
  
  belongs_to :user
  
  def self.get_activity_for_range(start, finish, object_class = '%', object_id = '%', action_name = '%')
    ChangeLog.count_by_sql("SELECT COUNT(id) FROM change_logs WHERE object_class LIKE '#{object_class}' AND object_id LIKE '#{object_id}' AND action LIKE '#{action_name}' AND performed_at > '#{start}' AND performed_at < '#{finish}'")
  end
end
