# Copyright 2010 The Apache Software Foundation.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Methods added to this helper will be available to all templates in the application.
require 'webrick/utils'

module ApplicationHelper
  include ViewsHelper

  def user
    request.env["REMOTE_USER"] or "nobody"
  end
  
  def group
    $group_map[user] if $group_map
  end

  # Help helpers

  def t_exists?(name)
    begin
      self.view_paths.find_template(name)
      return true
    rescue ActionView::MissingTemplate
      return false
    end
  end
  
  def help_exists?(context = nil, page=nil)
    return nil if context =~ /\</
    get_help_view(context,page) != nil
  end
  
  def get_all_help_pages
    Dir.glob(RAILS_ROOT + "/app/views/*/*_help*").sort.map {|name|
      if name =~ /app\/views\/([^\/]*)\/_(.*)_help\..*$/
	[$1,$2]
      else
	nil
      end
    }.compact.uniq.map {|context,page|
      category = context.humanize
      category = "General Topics" if context == "help"
      name = page.humanize
      if help_exists?(context,page)
	[category,name,context,page]
      else
	nil
      end
    }.compact.sort {|a,b|
      r = a[0] <=> b[0]
      if r != 0
	r
      else
	a[1] <=> b[1]
      end
    }
  end

  def get_help_view(cont,page)
    cont = nil if cont == ""
    page = nil if page == ""

    cont = cont.downcase if cont
    page = page.downcase if page

    cont ||= "index"

    return "#{cont}/help" if page.nil? and t_exists?("#{cont}/_help")

    return "#{cont}/#{page}_help" if page and t_exists?("#{cont}/_#{page}_help")

    return "#{cont.pluralize}/#{page}_help" if 
      page and t_exists?("#{cont.pluralize}/_#{page}_help")

    return "#{cont.singularize}/#{page}_help" if 
      page and t_exists?("#{cont.singularize}/_#{page}_help")

    return "help/#{cont}_help" if t_exists?("help/_#{cont}_help")

    return "help/#{cont.singularize}_help" if t_exists?("help/_#{cont.singularize}_help")

    return "help/#{cont.pluralize}_help" if t_exists?("help/_#{cont.pluralize}_help")

    return nil
  end


  
  def main_help_link(name, options = {}, html_options = {})
    name ||= image_tag("help.png")
    options[:after] = "document.getElementsByClassName('help_button').each(function(val) {val.show();})"
    options[:ignore_missing] = true
    html_options[:class] ||= "main_help_link"
    help_link name, nil, nil, options, html_options
  end
  
  def help_link(name, context = nil, page = nil, options = {}, html_options = {})
    #    link_to("help", :action => 'help')
    html_options[:class] ||= "help_button"    

    if options[:title] and options[:text]
      new_params = {:title => options[:title],
	:text =>options[:text]}
    else
      c = context
      p = page 

      c,p = name,nil if c.nil? and p.nil? and help_exists?(name,nil) 

      if not help_exists?(c,p) or (c.nil? and p.nil?)
	c ||= @controller.controller_name 
	p ||= @controller.action_name
      end           
    
      c,p = @controller.controller_name,context if not help_exists?(c,p) and not p
      
      exists = help_exists?(c,p)
      return nil if not
	exists and 
	options[:only_if_exists]
      
      if !options.delete(:ignore_missing) and !exists
	return "#{name}?!"
      end

      new_params = {:context => c,
	:page =>p}
    end

    if inline_help? or not help_page?
      options[:url] = {:controller => 'help', :action => 'inline'}.update(new_params)
      options[:update] = 'help'
      link_to_remote name, options, html_options
    else
      options[:url] = {:controller => 'help'}.update(new_params)
      options[:after] = nil
      link_to name, options, html_options
    end


  end
  
  def inline_help?
    help_page? and @controller.action_name == "inline"
  end

  def help_page?
    @controller.controller_name == "help"
  end

  def help_button(context = nil, page = nil, options = {}, html_options = {})
    if not help_page?
      html_options[:style] ||= "" 
      html_options[:style] += "display:none;" 
    end
    help_link image_tag('help.png'), context, page, options, html_options
  end

  def short_help(title, text)
    help_button(nil,nil,{:title => title, :text => text})
  end

  def help_goto(context = nil, page = nil, options = {}, html_options = {})
    help_link image_tag('goto.png'), context, page, options, html_options
  end

  def help_close_button
    if inline_help?
      help_link(image_tag('close.png'), "hidden", nil, 
		{:after => "document.getElementsByClassName('help_button').each(function(val) {val.hide();})"})
    else
      ""
    end
  end

  def help_title(text)
    "<h1 class='help'>#{h text} #{help_close_button}</h1>"
  end

  def help_subtitle(text)
    "<h2 class='help'>#{h text}</h2>"
  end

  def help_subsubtitle(text)
    "<h3 class='help'>#{h text}</h3>"
  end

  def help_notice(text)
    "<i class='help'>#{h text}</i>"
  end

  def title(title)
    return "<div class='homepageTitle'>#{h(title)} #{help_button nil,nil,{:only_if_exists => true} }</div>"
  end
  
#  def help_link(text)
#    link_to text, :controller => 'help', :context => text.downcase
#  end

  
  def hostname
    Socket.gethostname
  end

  def initialize_parameters
    Timeout.timeout(2) {
      load_session
      @chart = Chart.new(:time_range => nil) if params[:reset_chart] or @chart.nil?
      load_params

      @filters = [] unless @filters
      @conditions = @current_filter.conditions() if @current_filter
      @conditions = [] unless @conditions
      @conditions << @filters.map{|f| f.conditions}.flatten
      @paging_size = 10 unless @paging_size
      @page_number = 1 unless @page_number
      
      unless @current_filter
	@current_filter = Filter.new(:name => "Current Filter #{Time.now.strftime("%F %T")}") 
	unless params[:no_default_filter]
	  if params[:default_filter]
	    cond = Condition.create(nil, "SQL",params[:default_filter])
	  else
	    cond = Condition.create("date","DATE","today")
	  end
	  @current_filter.conditions = @current_filter.conditions.push(cond)
	end
      end

      save_session
    }

    if @current_filter 
      @current_filter.datasource = current_datasource
    end
#    if @filters
#      @filters.each {|filter| filter.datasource = datasource }
#    end

    if @chart and not @chart.mode == :view_only
      @chart.datasource = current_datasource
      @chart.conditions = get_condition_string if current_datasource
    end
    
  end

  # ----------- session -------------- #
  def state_id
    @state_id
  end
  TEST_STATE_ID = "random_id_used_for_testing"
  def current_session
    return session[@state_id] if @state_id
    @state_id = params[:state_id]
    if RAILS_ENV=="test"
      @state_id = TEST_STATE_ID
    else
      @state_id = WEBrick::Utils.random_string(20) unless @state_id
    end
    session[@state_id] = {} unless session[@state_id]
    return session[@state_id]
  end
  def clear_session
    session[@state_id] = nil
  end
  def save_session_value(key, value)    
    begin
      return current_session[key] = value.full_clone if value.respond_to?(:full_clone)
      return current_session[key] = value.clone if value.respond_to?(:clone)
    rescue TypeError
      current_session[key] = value
    end
  end
  def load_session_value(key)
    # fix, otherwise attributes_methods:160 will complain nil.[] on cached methods
    v = current_session[key]
    v.instance_eval("@attributes_cache ||= {}")

    if v and subclasses_of(ActiveRecord::Base).include?(v.class) and v.id
      begin
	new_val = v.class.find(v.id)
	new_val.attributes = v.attributes
	v = new_val
      rescue ActiveRecord::RecordNotFound
	flash[:error] = "Could not find '#{v.class}.#{v.id}'"
      end
    end
    v
  end
  SESSION_VALUES = [:filters,:chart,:current_filter,:zoom,:order,
    :page_number,:page_offset,:paging_size,:table_name]
  def save_session
    @zoom = @chart.zoom if @chart
    SESSION_VALUES.each {|name|
      save_session_value(name,instance_variable_get("@#{name}"))
    }
  end
  def load_session
    SESSION_VALUES.each {|name|
      instance_variable_set("@#{name}",load_session_value(name))
    }
    @chart.zoom = @zoom if @zoom
  end
  def clone_session
    old_session = current_session
    @state_id = nil
    params[:state_id] = nil
    
    old_session.each {|key,val|
      save_session_value(key,val)
    }

    load_session
    save_session
  end

  # ----------- datasource -------------- #

  def current_datasource
    return @table_class if @table_class and @table_class.table.table_name == @table_name
    if @table_name     
      @table_class = Prisma::Database.get_class_from_tablename(@table_name) if defined?(Prisma::Database)
      @table_class = View.get_class_from_tablename(@table_name) unless @table_class
      @table_class = GenericRecord.get_class_from_tablename(@table_name) unless @table_class
      @table_name = nil unless @table_class
    end
    @table_class
  end

  def current_table
    begin
      current_datasource.table
    rescue
      nil
    end
  end

  def get_condition_string(real = false, withoutrule = -1)
    #    return nil if not @current_filter
    #    return @current_filter.get_condition_string(real,withoutrule,{:banished_set => @banished_set,
    #                                           :negative_set => @negative_set,
    #
    #:global_rule_number => @global_rule_number})
    throw "No current filter defined." unless @current_filter
    throw "No datasource for current filter defined." unless @current_filter.datasource

    @current_filter.valid?
    table = current_table
    table = nil if (view = View.get_class_from_tablename(table.table_name)) and view.do_not_use_view_for_query

    @filters = [] unless @filters
    sql = (@filters.clone << @current_filter).compact.map {
      |f| f.get_condition_string(table,false,-1,{:flash => flash})
    }.compact.join(" AND ")
    return nil if sql == ""
    sql
  end

  # ----------- params -------------- #
  
  def load_params
    begin
      @filters = params[:filters].map { |id| Filter.find(id) } if params[:filters] 
      @order = params[:order] if params[:order]
      @table_name = params[:table] if params[:table] and !(params[:table].class.to_s =~ /Hash/)
      @table_name = params[:table_name] if params[:table_name]
      @paging_size = params[:paging_size].to_i if params[:paging_size]
      @paging_size = 10 if @paging_size == 0       
      
      if params[:page_number] and @page_number != params[:page_number].to_i
 	if @page_offset and @page_number 
	  @page_offset = @page_offset + @paging_size * (params[:page_number].to_i - @page_number)	  
	  @page_number = (@page_offset / @paging_size) + 1 # pagenumbers starts at 1
	else
	  @page_number = params[:page_number].to_i 
	  @page_offset = @page_number * @paging_size
	end	  
      else
	if params[:page_offset] and @page_offset != params[:page_offset].to_i
	  @page_offset = params[:page_offset].to_i  
	  @page_number = (@page_offset / @paging_size) + 1 #page_number starts at 1
	end
	@page_offset = 0 unless @page_offset
	@page_number = 1 unless @page_number
	if @page_offset < 0 or @page_number < 1 
	  @page_offset = 0
	  @page_number = 1
	end
      end 
            
      
      @chart = Chart.load_yaml(params[:chart_tmpdir_hash], params[:chart_yaml_hash]) if 
	params[:chart_tmpdir_hash]
      @chart = Chart.load_yaml(params[:chart_data_dir], params[:chart_yaml_hash]) if
	params[:chart_data_dir]
      @chart = Chart.find(params[:chart_id]) if params[:chart_id]

      if @chart and not @chart.mode == :view_only
	@chart.column1 = params[:chart_column1] if params[:chart_column1]
	@chart.column2 = params[:chart_column2] if params[:chart_column2]
	@chart.aggregation_column = params[:chart_aggregation_column] if params[:chart_aggregatino_column]
	@chart.aggregation_function = params[:chart_aggregation_function] if params[:chart_aggregation_function]
	@chart.chart_type = params[:chart_type] if params[:chart_type]
	@chart.order_by = params[:chart_order_by] if params[:chart_order_by]
	@chart.set_data_directory_from_hash = params[:chart_hash] if params[:chart_hash]
	@chart.attributes = (params[:chart]) if params[:chart] and params[:chart].class.name != "String"
      end
      
      load_current_object

#    rescue
#      flash[:warning] = "Error loading parameters. (#{$!})"
    end
  end
  
  # ------------- default object for CRUD ------------ #

  def load_current_object
    # first access the class that yaml can find it.
    # otherwise return
    return unless (obj_class rescue nil)
    if params[:current_object_zip]
      begin
	self.current_object = Object.from_zip(params[:current_object_zip]).clone
	flash[:info] = "Loaded zip of type #{current_object.class} to #{obj_instance_variable_name}"
	return self.current_object
      rescue
	flash[:error] = "Could not load zip '#{$!}'."
      end      
    end
    if params[:id]
      self.current_object = obj_class.find(params[:id])
      return self.current_object
    end
  end

  def obj_instance_variable_name
    "#{params[:controller].singularize}"
  end

  def obj_class_name
    params[:controller].singularize.camelize
  end

  def obj_class
    Object.const_get(obj_class_name) if Object.const_defined?(obj_class_name)    
  end
  
  def current_object
    instance_variable_get("@#{obj_instance_variable_name}")    
  end
  def current_object=(val)
    raise "Yaml object '#{val}' has type '#{val.class.name}' expected was '#{obj_class_name}'." unless val.class.name == obj_class_name
    instance_variable_set("@#{obj_instance_variable_name}",val)    
  end

  # ----------- paging -------------- #

  def reset_paging
    @page_offset = 0
    @page_number = 1
  end

  def get_params
    throw "To overwork"
    return nil unless @state_id
    { :filters => @filters.map { |f| f.id}.uniq,
      :order => @order,
      :table => @table_name,
      :page_number => @page_number,
      :page_offset => @page_offset,
      :paging_size => @paging_size}
  end
  

  # ----------- stuff -------------- #
  def safe_filename(name,type, date = DateTime.now)
    "#{(name or "UNKNOWN").gsub(/[^[:alnum:]\-\_]/, '_')}-#{date.strftime("%F%t")}.#{type}"
  end
  
  def create_links_in_query(query)
    return "" unless query
    query = h query
    query.gsub!(/(FROM[^[:alnum:]]*)(\`?[^ ]*\`?)|(\`?view_\d+\`?)|(\`?[[:alnum:]]*_metas\`?)/i) { |s|
      begin
	#	throw [query,$1,$2,$3,$4]
	prefix,table = $1,$2 if $1
	prefix,table = "",$3 if $3
	prefix,table = "",$4 if $4

	table_name = table
	table_name = table_name[1..-1] if table_name.starts_with?("`")
	table_name = table_name[0..-2] if table_name.ends_with?("`")

      	if GenericRecord.connection.tables.include?(table_name)
	  prefix + link_to(table,:controller => 'survey',
			   :action => 'show',
			   :table => table_name) 
	else
	  prefix + table
	end
#      rescue
#	s
      end
    }

    query.gsub!(/\*|\sWHERE\s|\sLIKE\s|\sAND\s|SELECT\s|\sFROM\s|\sAS\s|\sIN\s|\sCOUNT\s|\sSUM\s|\sJOIN\s|\sLEFT\s|\sRIGHT\s|\sINNER\s|\sOUTER\s|\sDISTINCT\s|\sGROUP\sBY\s|\sORDER\sBY\s|\sDESC\s|\sOR\s|\sLIMIT\s|\sLIMIT\s|OFFSET\s|UNION\s|ALL\s/i) { |s|
      "<b><i>#{s}</i></b>"
    }
  end

  # Common
  def page_title
    "#{controller.controller_name.humanize}: #{controller.action_name.humanize}"
  end

  def object_submenu(obj, actions = ["edit"])
    ret = []
    actions.each {|action|
      ret.push({:title => action, :link => url_for( :controller => obj.class.name.tableize, 
						   :action => action, 
						   :id => obj)})
    }
#    ret.push({:title => "<hr>"})
    ret.push({:title => "Number&nbsp;#{obj.id}"})
    ret.push({:title => obj.description}) if obj.respond_to?("description") and obj.description and obj.description.strip != ""
  end

  def auto_submenu(klass)
    [{:title => "New ...", :link => url_for(:controller => klass.name.tableize, :action => "new")}] +
      klass.find(:all,:order => "name").map {|obj|
      { :title => obj.name, :link => url_for( :controller => klass.name.tableize, 
					     :action => 'show', 
					     :id => obj),
	:submenu => object_submenu(obj)
      }
    }
  end

  def common_menu(main_name = "Alois", unfolded = true)
    views=[]
    views.push({ :title => "New ...", :link => url_for( :controller => 'views', :action => 'new') })
    
    all_views = View.find(:all).select {|view| view.exclusive_for_group.nil? or view.exclusive_for_group == ""  or view.exclusive_for_group == group}
    
    make_groups(all_views).each{|name,views_coll|
      
      sub_sub_entries = []
      
      if name == ""
	for view in views_coll
	  views.push({ :title => view.name, :link => url_for( :controller => 'survey', :table => view.table_name), :submenu => object_submenu(view, ["show","edit"])
		     })
	end
      else
	for view in views_coll
	  sub_sub_entries.push({ :title => view.name, :link => url_for( :controller => 'survey', :table => view.table_name),
				 :submenu => [
				   { :title => "show", :link => url_for( :controller => 'views', :action => "show", :id => view)},
				   { :title => "edit", :link => url_for( :controller => 'views', :action => "edit", :id => view)}
				 ]
			       })
	end
	
	views.push({ :title => (name or "Rest"), :submenu => sub_sub_entries})
      end
    }
             
    
    m = [
      {
	:title => main_name,
	:link => url_for(:controller => 'prisma'),
	:submenu => [
	  { :title => "Overview", :link => url_for( :controller => 'prisma')},
	  { :title => "Statistics", :link => url_for( :controller => 'prisma', :action => 'statistics')},
#	  { :title => "Bookmarks", :link => url_for( :controller => 'bookmarks')},
	  { :title => "Reports", :link => url_for( :controller => 'reports')},
	  { :title => "Alarms", :link => url_for( :controller => 'alarms')},
	  { :title => "Help", :link => url_for( :controller => 'help')},
	]
      },
      {
	:title => "Database",
	:link => url_for( :controller => 'prisma', :action => "databases"),
	:submenu => [
	  { :title => "Status", :link => url_for( :controller => 'prisma', :action => "databases")},
	  { :title => "Views",  :link => url_for( :controller => 'views'), :submenu => views},
	  { :title => "Ip Ranges", :link => url_for( :controller => 'ip_ranges')},
	  { :title => "Tables", :link => url_for( :controller => 'tablelist')},
	  { :title => "Schema", :link => url_for( :controller => 'tablelist',:action => 'schema')}
	]
      },
      {
	:title => "Reporting",
	:link => url_for( :controller => 'sentinels'),
	:submenu => [
	  { :title => "Sentinels", :link => url_for( :controller => 'sentinels'), :submenu => auto_submenu(Sentinel)},
	  { :title => "Report Templates", :link => url_for( :controller => 'report_templates'), :submenu => auto_submenu(ReportTemplate)},
	  { :title => "Charts", :link => url_for( :controller => 'charts'), :submenu => auto_submenu(Chart)},
	  { :title => "Filters", :link => url_for( :controller => 'filters'), :submenu => auto_submenu(Filter)}
	]
      }
    ]


=begin
    if @controller.class == FiltersController or unfolded 
      sub_entries=[]
      sub_entries.push({ :title => "Create new filter", :link => url_for( :controller => 'filters', :action => 'new') })
      for filter in Filter.find(:all)
	sub_entries.push({ :title => filter.name, :link => url_for( :controller => 'filters', :action => 'show', :id => filter ) })
      end
      m.push({ :title => 'Filters', :link => url_for( :controller => 'filters' ), :submenu => sub_entries })
    end
=end
    
    m.push({ :title => 'Views', :link => url_for( :controller => 'views' ), :submenu => views })
    
    m
  end

  def place_holder(width, height, options = {})
    options[:width] = width
    options[:height] = height
    options[:border] = '0'
    
    return image_tag("dot.gif", options)
  end

  def main_menu(menu)
    result = '<div id="menu" >' + "\n" 
    for entry in menu
      result += '<ul>' + "\n"
      result += '<li><h2>' + "\n"
      result += link_to(entry[:title], entry[:link])  + "\n"
      result += '</h2>' + "\n"
      result += sub_menues(entry)
      result += '    </li>' + "\n"
      result += '</ul>' + "\n"
    end 
    
    result += '</div>' + "\n"
  end

  def sub_menues(entry)
    return "" unless entry
    result = ""
    if entry[:submenu] and entry[:submenu].length > 0
      result += '        <ul>' + "\n"
      for sub_entry in entry[:submenu] 
	if sub_entry[:link]
	  result += '          <li>' + link_to(sub_entry[:title], sub_entry[:link]) + sub_menues(sub_entry) + '</li>' + "\n"
	else
	  result += '          <li>' + sub_entry[:title].to_s + sub_menues(sub_entry) + '</li>' + "\n"
	end
      end 
      result += '        </ul>' + "\n"
    end 
    return result
  end

  # error messages
  def error_messages_for_depr(*params)
    return ActionView::Helpers::ActiveRecordHelper.error_messages_for(*params)
    options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}
    objects = params.collect { |object_name| instance_variable_get("@#{object_name}") }.compact
    
    errors = []
#    errors.push(flash[:error]) unless flash[:error].nil?
#    error_messages = objects.map { |object| errors.concat(object.errors.full_messages) unless object.errors.full_messages.empty? }
    
    warnings = []
#    warnings.push(flash[:warning]) unless flash[:warning].nil?

    notices = []
#    notices.push(flash[:notice]) unless flash[:notice].nil?

    render :partial => '/messages', :locals => { :errors => errors.flatten, :warnings => warnings.flatten, :notices => notices.flatten }
  end

  def error_messages
    return nil
    error_messages_for nil
  end


  def render_remote(url, options = {})
    options[:update_color] ||= "red"
    options[:container] ||= "div"
    options[:text] ||= "Bitte warten, der Inhalt wird geladen..."
    url[:layout] ||= "false"

    div_id = "auto_refresh_#{WEBrick::Utils.random_string(10)}"
    ret = ""
    if options[:frequency]
      ret += periodically_call_remote(:frequency => options[:frequency],
				      :before => "Element.setStyle('#{div_id}', {backgroundColor : '#{options[:update_color]}'});",
				      :loaded => "Element.setStyle('#{div_id}', {backgroundColor : 'transparent'});",
				      :update => div_id, 
				      :url => url)      
      ret += "<div>Auto reload after #{pluralize(options[:frequency],"second")}</div>"
    end
    ret += "<#{options[:container]} id=\"#{div_id}\">"
    ret += javascript_tag remote_function(:update => div_id, :url => url)
    ret += options[:text]
    ret += "</#{options[:container]}>"   
    ret
  end


  def bookmark_add_link(text = nil)
    text ||= image_tag "bookmark_add.png"
    link_to text, :controller => "bookmarks", :action => "new",
      "bookmark[title]" => "Neuer Bookmark",
      "bookmark[controller]" => params[:controller],
      "bookmark[action]" => params[:action],
      "bookmark[table_name]" => @table_name,
      "bookmark[identifier]" => params[:id]

     
  end

  def fobj(obj, action = "show", text = nil)
    return "NONE" unless obj

    if obj.respond_to?(:name)
      txt = (text or (h(obj.name) or "NONAME"))
      txt = "NONAME" if txt == ""
    else
      txt = (text or h("#{obj.class.name}.#{obj.id}"))
    end
    
    link_to(txt, :controller => obj.class.name.tableize, :action => action, :id => obj)
  end

  def post_attributes_show
    if current_object
      "<tr><th>Serialized</th>" + 
	"<td><pre>#{current_object.to_zip rescue $!}</pre></td>" + 
	"</tr>"    
    end
  end
  
  def post_attribute_new
    _erbout = ''
    form_tag(:action=>'new', :state_id => @state_id) do
      _erbout.concat("<tr><th class='form_header' colspan='2'>Upload</th></tr>"+
      "<tr><th>ZIP</th><td>" + text_area_tag('current_object_zip', '', :rows => 4) + "</td></tr>" +
      "<tr><td class='button-bar' colspan='2'>" + submit_tag("Load") + submit_tag("Cancel") + "</td></tr>")
    end
  end

  def datasource_fields
    remote_function = remote_function(:update => "filters_list",
				      :before => 'document.getElementById("filters_list").innerHTML = "Loading...";',
				      :with => "'table=' + document.getElementById('table_name').options[document.getElementById('table_name').selectedIndex].value",
				      :url => { :controller => "filters", :action => "list_possible_filters" })
    


    sources = Prisma::Database.data_sources
    if block_given?
      sources = sources.select {|s| (yield s) rescue false}
    end
    sources = sources.map {|s| ["#{s.name} (#{s.table_name})",s.table_name]}
    sources = sources.sort_by{|x| (x[0] or "")}
    
    "Datasource: #{select_tag('table_name', options_for_select(sources),:onChange => remote_function)}<br>" +
      "Time Range: #{text_field_tag "time_span","today"}<br>" +
      "Filters: #{text_field_tag "filters"} (id, id, id)<br><div id='filters_list'><br></div>"
  end

  def parse_datasource_parameters
    d = current_datasource
    
    c = Condition.create("date","DATE",params[:time_span]) if
      params[:time_span] and params[:time_span] != ""      
    c = ([c] + Filter.parse_text_field(params["filters"])).compact.map {|f| f.sql(:table_class => @datasource)}.join(" AND ")
    [d,c]
  end


  # show hide
  def show_hide(id, css_class = "show_hide")
    if css_class
      "class='show_hide' "
    else
      ""
    end + "onmouseover=\"showElement(this,'sh_#{id}')\" onmouseout=\"hideElement(this,'sh_#{id}')\""
  end

  def show_hide_element(id)
    "id='sh_#{id}' class='show_hide_element' onmouseover=\"showElement(this,'sh_#{id}')\" onmouseout=\"hideElement(this,'sh_#{id}')\""
  end
  
  def show_hide_script
    <<eof
<script>
function log(text) {
/* document.getElementById("log").innerHTML += text.toString() + "<br>";  */
}

var shownElements = new Array();
function showElement(caller,id) {
  log("showElement(" + caller + "," + id + ")");
  var element = document.getElementById(id);
  element.style.display = 'block';
  shownElements.push(id);
}

function hideElement(caller,id) {
  log("hideElement(" + caller + ","  + id + ")");
  var element = document.getElementById(id);

  // remove from shown elements
  for (i = 0; i < shownElements.length; i++) {
    if (shownElements[i] == id) {
      shownElements.splice(i,1);
    }
  }

  setTimeout("finallyHideElement('" + id + "')", 100);
}

function finallyHideElement(id) {
  log("finallyHideElement(" + id + ")");
  var hide = true;
  for (i = 0; i < shownElements.length; i++) {
    if (shownElements[i] == id) {
      hide = false;
    }
  }
  if (hide) {
    document.getElementById(id).style.display = 'none';
  }
}

</script>
eof
end
end
