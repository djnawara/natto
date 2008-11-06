require 'htmlentities'

class PagesController < CrudController
  before_filter :find_object, :only => [:home, :admin, :show, :show_by_title, :edit, :update, :destroy, :purge, :undelete, :approve, :publish, :unpublish, :set_display_order, :set_parent, :roles, :process_role]
  before_filter :page_found_check,    :only => [:show, :show_by_title, :home]
  before_filter :role_check_required, :only => [:show, :show_by_title, :home]
  skip_before_filter :login_required, :only => [:show, :show_by_title, :home, :sitemap]
  skip_before_filter :admin_required, :only => [:show, :show_by_title, :home, :sitemap]
  
  skip_before_filter :verify_authenticity_token
  
  # These aren't stricly necessary, but do give the user some feedback
  # as to why an action isn't working (the action won't succeed).
  before_filter :only => :approve do |controller|
    controller.send(:state_check, :pending_review)
  end
  
  before_filter :only => :publish do |controller|
    controller.send(:state_check, [:approved, :unpublished])
  end
  
  before_filter :only => :unpublish do |controller|
    controller.send(:state_check, :published)
  end
  
  before_filter :only => :destroy do |controller|
    controller.send(:state_check, [:pending_review, :approved, :published, :unpublished])
  end
  
  before_filter :only => :undelete do |controller|
    controller.send(:state_check, :deleted)
  end
  
  # This check is necessary to make sure only :deleted state items are destroyed.
  before_filter :only => :purge do |controller|
    controller.send(:state_check, :deleted)
  end
  
  def get_json
    #ActionController::Routing::Routes.to_json if logged_in? && current_user.is_administrator?
    #[{:route => '/pages/new',:title => 'add page'}, {:route => '/pages/new',:title => 'edit'}, {:route => '/pages/new',:title => 'add user'}]
    routes = []
    if logged_in? && current_user.is_administrator?
      controller_names = ActionController::Routing.possible_controllers.reject{|name| name.include?('rails') || name.eql?('crud')}
      controller_names.each do |name|
        controller = Kernel.const_get(name.split(/_/).collect{|word|word.capitalize}.join + 'Controller')
        ['new', 'index', 'home', 'show_by_title', 'sitemap', 'admin'].each do |method|
          routes << {:route => ('/' + name + '/' + method), :title => name + ' ' + method} if controller.method_defined?(method) unless should_not_list?(name, method)
        end
      end
    end
    routes
  end
  private :get_json
  
  # Add an entry to config/hide_from_js_nav.yml,
  # for any actions which you do not want listed in the JSON.
  def should_not_list?(name, method)
    DO_NOT_LIST.include?({'controller' => name, 'action' => method})
  end
  private :should_not_list?
  
  # GET /pages
  # GET /pages.xml
  def index
    @objects = Page.find(:all, :conditions => {:parent_id => nil}, :order => 'display_order')
    respond_to do |format|
      format.html { render :layout => 'ajax', :template => 'pages/index' }
      format.xml  { render :xml => @objects }
    end
  end
  
  def update_positions
    counter = 1
    params[:page_tree].each do |index, branch|
      update_tree(branch, nil, counter)
      counter += 1
    end
    @objects = Page.find(:all, :conditions => {:parent_id => nil}, :order => 'display_order')
    render :layout => false, :template => "pages/index"
  end
  
  # assumes that each set of nodes contains a key "id", and that the rest are ordered numeric keys
  def update_tree(branch, parent_id = nil, position = 1)
    page = Page.find_by_id(branch["id"])
    unless page.nil?
      page.parent_id = parent_id
      page.display_order = position
      page.save(false) # save without validating the page
      # if anything is left after removing the id, we have children
      branch.delete("id")
      counter = 1
      branch.sort.each do |index, child|
        update_tree(child, page.id, counter)
        counter += 1
      end
    end
  end
  
  def home
    show
  end
  
  def admin
    respond_to do |format|
      format.html # admin.html.erb
      format.xml  { render :xml => @object }
      format.js   { render :json => get_json }
    end
  end
  
  def sitemap
    @objects = Page.find_in_state(:all, :published, :conditions => {:parent_id => nil}, :order => 'is_home_page DESC, is_admin_home_page, display_order').reject {|page| page.roles.size > 0}
    respond_to do |format|
      format.html # sitemap.html.erb
      format.xml  { render :xml => @objects }
    end
  end
  
  # GET /pages/1
  # GET /pages/1.xml
  def show
    if @object.current_state != :published
      flash.now[:warning] = "This is a preview.  This page is not published."
    end
    respond_to do |format|
      format.html do
        case @object.page_type
        when Page::NORMAL
          render :template => "pages/show"
        when Page::BLOG
          render :template => "pages/blog"
        when Page::PORTFOLIO
          @objects = Project.active
          render :template => "pages/portfolio"
        when Page::BIOGRAPHY
          @objects = Biography.find(:all, :order => "name")
          render :template => "pages/biography"
        else
          render :template => "pages/show"
        end
      end
      format.xml  { render :xml => @object }
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show_by_title
    # Handle advanced pathing
    unless @object.advanced_path.blank?
      begin
        redirect_to(self.send(@object.advanced_path, params[:args]))
        return
      rescue Exception => err
        flash_exception(err, "Advanced Path Error")
      end
    end
    show
  end
  
  # GET /pages/new
  # GET /pages/new.xml
  def new
    @object = Page.new(:parent_id => params[:parent_id])
    respond_to do |format|
      format.html { render :template => 'pages/form' }
      format.xml  { render :xml => @object }
    end
  end
  
  # POST /objects
  # POST /objects.xml
  def create
    @object = Page.new(params[:page])
    Page.transaction do
      @object.save!
      create_change_log_entry
    end
    respond_to do |format|
      flash[:notice] = 'The page was successfully created.'
      format.html do
        if @object.advanced_path.blank?
          redirect_to @object
        else
          # make sure we catch bad paths here
          begin
            redirect_to(self.send(@object.advanced_path))
          rescue Exception => err
            flash_exception(err, "Advanced Path Error")
            redirect_to pages_path
          end
        end
      end
      format.xml  { render :xml => @object, :status => :created, :location => @object }
    end
  end
  
  # PUT /pages/:id
  # PUT /pages/:id.xml
  def update
    Page.transaction do
      # check if setting as new home page
      check_setting_home_page
      @object.update_attributes!(params[:page])
      create_change_log_entry
    end
    respond_to do |format|
      flash[:notice] = 'Page was successfully updated.'
      format.html { redirect_to((@object.advanced_path.blank? ? @object : self.send(@object.advanced_path))) }
      format.xml  { head :ok }
    end
  end
  
  def check_setting_home_page
    if !@object.is_home_page? && params[:page][:is_home_page].to_i == 1
      old_home_page = Page.home.first
      # make the old home page standard
      old_home_page.is_home_page = false
      # set new page order for the object
      @object.remove_from_display_order
      #push to top of heirarchy
      @object.parent = nil
      # save now so that the old home page can find the proper display order
      @object.save
      # now locate where to put the old home page
      old_home_page.add_to_display_order
      # save the old home page as a regular page
      old_home_page.save
    end
  end
  private :check_setting_home_page

  # DELETE /pages/:id
  # DELETE /pages/:id.xml
  #
  # Perform non-destructive delete.  To permanently destroy the object,
  # see purge.
  def destroy
    Page.transaction do
      @object.delete!
      reorder(Page.find(:all, 
        :conditions => {:parent_id => @object.parent_id, 
                        :is_home_page => false, 
                        :is_admin_home_page => false, 
                        :aasm_state => Page.states.collect{|state|state.to_s}.reject{|state| state.eql?('deleted')}}, 
        :order => 'display_order ASC'))
      create_change_log_entry
    end
    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.xml  { head :ok }
    end
  end

  # DELETE /pages/:id/purge
  # DELETE /pages/:id/purge.xml
  def purge
    Page.transaction do
      id = @object.id
      @object.destroy
      create_change_log_entry(id)
    end
    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.xml  { head :ok }
    end
  end
  
  def undelete
    Page.transaction do
      @object.undelete!
      create_change_log_entry
    end
    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.xml  { head :ok }
    end
  end
  
  def publish
    Page.transaction do
      @object.publish!
      create_change_log_entry
    end
    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.xml  { head :ok }
    end
  end
  
  def unpublish
    Page.transaction do
      @object.unpublish!
      create_change_log_entry
    end
    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.xml  { head :ok }
    end
  end
  
  def approve
    Page.transaction do
      @object.approve!
      create_change_log_entry
    end
    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.xml  { head :ok }
    end
  end
  
  # This sets a page's display order based on passed in values.
  # Doing this as a single method will set us up for an AJAXified
  # drag and drop list.
  def set_display_order
    new_display_order = params[:display_order].to_i
    old_display_order = @object.display_order
    if new_display_order == old_display_order
      flash[:warning] = "No changes made."
      redirect_to(pages_url)
      return false
    end
    
    # This sets up to renumber the _other_ pages, not the one targeted.
    # if the old number is larger than the new number, then we need to re-number as follows:
    if old_display_order > new_display_order
      start = new_display_order         # start at the new number...
      finish = old_display_order - 1    # and go until 1 less than the old number
    else
      start = old_display_order + 1     # start one above the old number, and...
      finish = new_display_order        # go until the new number
    end
    
    # collect the siblings which need re-ordering
    counter = 0
    Page.find(:all,
      :conditions => {:parent_id => @object.parent_id, :display_order => (start..finish)},
      :order => 'display_order ASC'
    ).each do |page|
      logger.debug('setting display_order for "' + page.title + '"')
      page.display_order = counter + old_display_order
      page.save(false)
      counter += 1
    end
    
    # now set the page we're moving
    @object.display_order = new_display_order
    @object.save(false)
    
    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.xml  { head :ok }
    end
  end
  
  # Change the page's parent with links
  def set_parent
    parent = params[:parent_id].nil? ? nil : Page.find_by_id(params[:parent_id].to_i)
    if parent == @object.parent
      flash[:warning] = "No changes made."
      redirect_to(pages_url)
      return false
    end
    
    old_parent_id = @object.parent_id
    @object.parent = parent
    @object.display_order = Page.max_display_order(@object) + 1
    @object.save(false)
    
    # Reset all of the display order values.
    # Make sure to exclude the home and admin pages from the reorder,
    # when the parent_id was nil.
    reorder(Page.find(:all, :conditions => {:parent_id => old_parent_id, :is_home_page => false, :is_admin_home_page => false}, :order => 'display_order ASC'))
    
    create_change_log_entry
    
    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.xml  { head :ok }
    end
  end
  
  # Redo the display orders for the supplied nodes.
  def reorder(pages = [])
    counter = 1
    pages.each do |page|
      page.display_order = counter
      page.save(false)
      counter += 1
    end
    counter > 1 ? true : false
  end
  private :reorder
  
  def roles
    @available_roles = Role.find(:all).reject {|role| @object.roles.include?(role)}
  end
  
  def process_role
    case params[:commit]
    when 'Add role'
      role = Role.find_by_id(params[:role_id])
      @object.roles << role unless @object.roles.include?(role)
      @object.save(false)
      create_change_log_entry(nil, nil, 'add role', "Adding the '#{role.title}' role.")
    when 'Remove role'
      role = Role.find_by_id(params[:role_id])
      @object.roles.delete(role)
      @object.save(false)
      create_change_log_entry(nil, nil, 'remove role', "Removing the '#{role.title}' role.")
    end
    respond_to do |format|
      format.html { redirect_to(roles_page_path(@object)) }
      format.xml  { head :ok }
    end
  end
  
  # Throws a 404 if no page object is found.
  # Throws a 501 if the home page is not published.
  def page_found_check
    if @object.nil?
      if params[:action].eql?('home')
        render :template => 'pages/under_construction', :status => 501
      else
        render :template => 'pages/not_found', :status => :not_found
      end
    end
  end
  protected :page_found_check
  
  # Checks all page roles against current user roles
  def role_check_required
    @object.roles.each do |role|
      if logged_in?
        access_denied unless current_user.has_role?(role.title)
      else
        permission_denied
      end
    end
  end
  protected :role_check_required
  
  # Makes sure the object is in the proper state for the requested action.
  def state_check(states)
    failed = false
    states = [states] unless states.is_a?(Array)
    logger.debug('STATE CHECK: [' + states.collect { |state| state.to_s }.join(' || ') + ']')
    
    unless states.include?(@object.current_state)
      flash[:error] = '<h2>Invalid state for action.</h2>The requested action requires the <code>[' + states.collect { |state| state.to_s }.join(' || ') + ']</code> state.'
      redirect_to(pages_path)
    end
  end
  private :state_check
  
  # Any function which might return a page to a user must use this function.
  # This function gives the other filter functions access to the page to be returned, 
  # as well as the final function.
  def find_object
    title = params[:title].is_a?(Array) ? params[:title].join(' ') : params[:title]
    title = title.split(/_/).collect{|word| word.capitalize}.join(' ') if params[:title]
    id = params[:id].to_i if params[:id]
    
    if logged_in? && current_user.is_administrator?
      # grab by title if found, else by id, and if no id then grab the home page
      if title
        logger.debug('Locating page by title: ' + title)
        @object = Page.find_by_title(title)
      elsif id
        logger.debug('Locating page by id: ' + id.to_s)
        @object = Page.find_by_id(id)
      elsif params[:action].eql?('home')
        logger.debug('Locating home page')
        @object = Page.find_by_is_home_page(true)
      elsif params[:action].eql?('admin')
        logger.debug('Locating admin home page')
        @object = Page.find_by_is_admin_home_page(true)
      end
    else
      # grab by title if found, else by id, and if no id then grab the home page
      if title
        conditions = {:title => title}
      elsif id
        conditions = {:id => id}
      elsif params[:action].eql?('home')
        conditions = {:is_home_page => true}
      end
      
      # users require a page state check
      @object = Page.find_in_state(:first, :published, :conditions => conditions)
    end
    @page = @object
  end
  protected :find_object
  
  def flash_exception(exception = nil, title = "Error", now = false)
    return if exception.nil?
    coder = HTMLEntities.new
    content = "<h2>#{title}</h2><p>#{coder.encode(exception.message)}</p>"
    now ? flash.now[:error] = content : flash[:error] = content
  end
  private :flash_exception
end
