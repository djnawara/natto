require 'gchart'

class ChangeLogsController < ApplicationController
  def index
    conditions = {}
    conditions = conditions.merge({:object_class => params[:object_class]}) if params[:object_class]
    conditions = conditions.merge({:action => params[:action_name]}) if params[:action_name]
    conditions = conditions.merge({:object_id => params[:object_id]}) if params[:object_id]
    get_year_activity
    @objects = ChangeLog.find(:all, :conditions => conditions, :order => 'performed_at DESC')
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @objects }
    end
  end
  
  def get_year_activity
    # Get activity for the last several weeks
    @activity = []
    # find object class and id
    object_class = params[:object_class] || '%'
    object_id = params[:object_id] || '%'
    action_name = params[:action_name] || '%'
    # Grab data for the last 52 weeks (1 year)
    max = 0
    (0..51).each do |count|
      value = ChangeLog.get_activity_for_range((count + 1).weeks.ago.to_s(:db), count.weeks.ago.to_s(:db), object_class, object_id, action_name).to_i
      max = value if value > max
      @activity << value
    end
    
    @chart_url = Gchart.bar(
      :size => '320x20',
      :title => nil, # 'Activity',
      :title_size => 15,
      :title_color => '666666',
      :bg => 'ffffff',
      :bar_colors => '6666ff',
      :axis_with_labels => ['x'],
      :custom => 'chxs=0,666666,1&chds=1,' + (max + 1).to_s, # changes label color, drops font size to 1 (to just make hashes)
      :bar_width_and_spacing => {:width => 5, :spacing => 1},
      :data => @activity)
  end
  private :get_year_activity
end
