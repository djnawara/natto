class NattoBase < ActiveRecord::Base
  self.abstract_class = true
  
  ####################################
  # Retrieve author from the change log
  def author
    if log = ChangeLog.find(:first, :conditions => {:object_class => self.class.name.downcase, :object_id => self.id, :action => 'create'}, :order => 'performed_at DESC')
      log.user
    end
  end
  
  ####################################
  # Retrieve times from the change log
  def created_at
    action_performed_at('create')
  end
  
  def updated_at
    action_performed_at('update')
  end
  
  def deleted_at
    action_performed_at('destroy')
  end
  
  def activated_at
    action_performed_at('activate')
  end
  
  def suspended_at
    action_performed_at('suspend')
  end
  
  def unsuspended_at
    action_performed_at('unsuspend')
  end
  
  def action_performed_at(action = 'create')
    if log = ChangeLog.find(:first, :conditions => {:object_class => self.class.name.downcase, :object_id => self.id, :action => action}, :order => 'performed_at DESC')
      log.performed_at
    end
  end
  protected :action_performed_at
end