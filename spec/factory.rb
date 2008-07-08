module Factory

  def self.included(base)
    base.extend(self)
  end

  def build(params = {})
    raise "There are no default params for #{self.name} declared in #{__FILE__}" unless self.respond_to?("valid_#{self.name.underscore}_hash")
    new(self.send("valid_#{self.name.underscore}_hash").merge(params))
  end

  def build!(params = {})
    obj = build(params)
    obj.save!
    obj
  end

  def valid_user_hash
    { :login                  => 'david',
      :email                  => 'dave@djn2ms.com',
      :first_name             => 'Dave',
      :last_name              => 'Nawara',
      :password               => 'foobar',
      :password_confirmation  => 'foobar' }
  end

  def valid_page_hash
    { :title                  => 'Testing page',
      :description            => 'This page is strictly for testing.',
      :content                => '<h1>Testing page</h1><p>This is content?</p>',
      :aasm_state             => 'published',
      :display_order          => 1,
      :parent_id              => nil,
      :advanced_path          => nil }
  end
  
  def valid_role_hash
    { :title                  => 'Testing role',
      :description            => 'This is a fake role for testing purposes.' }
  end
  
  def valid_change_log_hash
    { :object_class           => 'change_log',
      :object_id              => '1234',
      :user_id                => '541702176',
      :action                 => 'test',
      :performed_at           =>  Time.now.to_s(:db),
      :comments               => 'This is a factory made change_log entry.' }
  end
end

ActiveRecord::Base.class_eval do
  include Factory
end
