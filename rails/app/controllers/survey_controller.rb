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

class SurveyController < ApplicationController
  include ApplicationHelper
  include SurveyHelper
  before_filter :handle_cancel, :only => [ :create, :update ]
  before_filter :init

  def init
    initialize_parameters
  end
  
  private

  def handle_cancel
    if params[:commit] == "Cancel"
      redirect_to :action => :list
    end
  end

  public
  def index
    redirect_to :action => 'list', :transport => params[:transport], :msg_type => params[:msg_type], :application => params[:application], :table_postfix => params[:table_postfix]
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :list }

  def get_desc(i)
    return nil
    conditions = @conditions
    conditions = [[nil,nil,nil,nil]] if @conditions.length ==0
    value = conditions[i][2]
    value = YAML.dump(value) unless value.class.name == "String"
    ret = [
      ["Column name or name of the rule.","Column/Name",
        nil,nil,nil,conditions[i][0],nil],
      ["Operator for the rule.","Operator",
        nil,nil,nil,conditions[i][1],nil],
      ["Value to compare for the rule.","Value",
        nil,nil,nil,value,nil],
      ["Percentage of items matched this rule.","%",
        get_condition(i), nil, "ALL", nil, "del_condition","d"],
      ["All values matched by that rule, and are in this sample.","In %",
        get_condition_string(true), nil, get_condition(i), nil,nil,nil],
      ["All values matched by that rule, that are not in this sample.","Not In %",
        get_condition(i), get_condition_string(true) , get_condition(i), nil,'negate_all_but','>'],
      ["How many records more would be in the sample if this rule where deleted.","Banish",
        get_condition_string(true,i),get_condition_string(true), nil, nil,'banished', '>'],
      ["Disable/Enable the rule.","",
        nil, nil, nil, if conditions[i][3] then "on" else "off" end, 'toggle', '>']
    ]
  end

  def report
    conditions = get_condition_string
    #flash[:notice] = "conditions: #{conditions}"
    #    @pages, @records = paginate current_table_class,
    #      :per_page => 100,
    #      :conditions => conditions,
    #      :joins => @join,
    #      :select => params[:select],
    #      :count => params[:count],
    #      :order => params[:order]

    #    @pages = Paginator.new self, params[:count].to_i, params[:page]
    #    sql = @current_filter.get_sql
    #    # this should be done by activerecord
    #    sql = "SELECT * FROM (#{sql}) AS survey_table " +
    #      " LIMIT #{@pages.current.offset},#{@pages.items_per_page}"
    #    @records = current_table_class.find_by_sql(sql)
  end

  def list_inline
    begin
      do_list
      render :partial => 'table'
    rescue
      render :text => "Message:<br><pre>#{$!.message}\n</pre>Trace:<br><pre>#{$!.backtrace.join("\n")}</pre>", :layout => false
    end
  end

  private

  def report_table_methods
    return nil unless params[:show_originals]
    ["original_text"]
  end
  def report_table(options = {})
    if params[:type] == "chart"
      data = @chart.get_data
      table = Ruport::Data::Table.new(:column_names => data[0].keys.map {|k| k == "data" ? @chart.data_column : k})
      data.each {|row|
	table << data[0].keys.map {|k| row[k]}
      }
      @data = table
    else
      conditions = get_condition_string()
      @data = current_table.report_table(:all,
					 :conditions => get_condition_string,
					 :methods => report_table_methods,
					 :order => @order)
    end
  end

  public

  def text
    #:max_col_width: Ordinal array of column widths. Set automatically but can be overridden. 
    #:alignment: Defaults to left justify text and right justify numbers. Centers all fields when set to :center. 
    #:table_width: Will truncate rows at this limit. 
    #:show_table_headers: Defaults to true 
    #:show_group_headers: Defaults to true 
    #:ignore_table_width: When set to true, outputs full table without truncating it. Useful for file output.     
    txt = report_table.as(:text, :ignore_table_width => true)
    send_data(txt,
	      :type => 'text/plain; charset=iso-8859-1; header=present',
	      :filename => safe_filename(current_datasource.name,"txt"))
  end

  def csv
    #:style Used for grouping (:inline,:justified,:raw) 
    #:format_options A hash of FasterCSV options 
    #:show_table_headers True by default 
    #:show_group_headers True by default
    csv = report_table.as(:csv)   
    send_data(csv,
	      :type => 'text/csv; charset=iso-8859-1; header=present',
	      :filename => safe_filename(current_datasource.name,"csv"))
  end

  def pdf
    # General:
    #  * paper_size  #=> "LETTER"
    #  * paper_orientation #=> :portrait
    #
    # Text:
    #  * text_format (sets options to be passed to add_text by default)
    #
    # Table:
    #  * table_format (a hash that can take any of the options available
    #      to PDF::SimpleTable)
    #  * table_format[:maximum_width] #=> 500
    #
    # Grouping:
    #  * style (:inline,:justified,:separated,:offset)
    pdf = report_table.as(:pdf)
    send_data(pdf,
	      :type => 'application/pdf',
	      :filename => safe_filename(current_datasource.name,"pdf"))
  end


  def list
    return redirect_to( :action => "list", :state_id => @state_id) unless params[:state_id]
    do_list
  end
  
  def add_condition
   # leave this for backwards compatibility
    @current_filter.conditions = @current_filter.conditions << 
      Condition.create(params[:column], params[:operator], params[:value]) if
      params[:column]
    @current_filter.conditions = @current_filter.conditions << 
      Condition.create(params[:column2], params[:operator2], params[:value2]) if 
      params[:column2]

    params[:columns].each_with_index {|col, i|
      @current_filter.conditions = @current_filter.conditions << 
	Condition.create(params[:columns][i], params[:operators][i], params[:values][i])
    } if params[:columns] and params[:operators] and params[:values]
    
    reset_paging
    save_session
    redirect_to :action => 'list', :state_id => @state_id # unless params[:state_id]
  end

  def create_view
    conditions = get_condition_string() ? " WHERE " + get_condition_string : ""
    sql = "SELECT * FROM #{current_table.table_name} #{conditions}"
    view = View.create(:sql_declaration => sql, :id_source_table => current_table.table_name)
    view.save

    redirect_to :controller => "views", :action => "edit", :id => view
  end

  def create_view_from_query
    @record = current_table.find(params[:id])
    names = []
    cols =  params[:select_columns].map { |c|
      c =~ /(.*)\.\`(.*)\`/
      if names.index($2) == nil
	ret = "#{c}"     
      else
	ret = "#{c} AS #{$1}_#{$2}"     
      end
      names.push($2)      
      ret
    }.join(", ")
    view = View.create(:sql_declaration => "SELECT #{cols} FROM #{@record.join_query}", :id_source_table => current_table.table_name)
    view.save

    redirect_to :controller => "views", :action => "edit", :id => view
  end
  
  def do_list    
    throw "Table not found." unless current_table
    conditions = get_condition_string

    @raw_descriptions = get_desc(-1)
    @descriptions = []

    origin = current_table.table_name
    origin = "( #{current_table.sql_declaration} ) AS #{origin}" if current_table.respond_to?(:sql_declaration)

    @query_string = "SELECT * FROM #{origin}"
    @query_string = @query_string + " WHERE #{get_condition_string}" if conditions

    begin
      @records = current_table.paginate(:page => @page_number.to_i,
					:per_page => @paging_size.to_i,
					:total_entries => if count_fast then count_fast else 100000 end,
					:conditions => conditions,
					:order => @order,
					:limit  =>  @paging_size.to_i,
					:offset =>  @page_offset)
      @query_string = (current_table.last_executed_find or @query_string) if current_table.respond_to?(:last_executed_find)
    rescue
      @records = nil
      flash[:error] = "Error executing query: #{$!}"
    end
				    

#    @pages = Paginator.new self, 
#      if count_fast then count_fast else 100000 end,
#      @paging_size.to_i,
#      @page_number.to_i
#    @records = current_table.find :all, 

  end

  def count_text
    render :partial => 'count_text'
  end

  def show
    if params[:id]
      @record = current_table.find(params[:id])
    else
      # show table or view description
      if @table_class.class == View
	redirect_to :controller => "views", :action => "show", :id => @table_class.id
      else
	redirect_to :controller => "tablelist"
      end
    end
  end

  def original_inline
    @record = current_table.find(params[:id])
    render :partial => "original"
  end

  def add_filter
    if params[:survey] and params[:survey][:filter_id] 
      @filters << Filter.find(params[:survey][:filter_id])
      @filters = @filters.uniq
      save_session
    end
    render :partial => "edit_named_filters"
  end

  def remove_filter
    @filters.delete(Filter.find(params[:filter_id].to_i))
    @filters = @filters.uniq
    save_session
    render :partial => "edit_named_filters"
  end

  def chart
    return redirect_to( :action => "chart", :state_id => @state_id) unless params[:state_id]
    save_session
    @query_string = @chart.query
    @chart.delete_data if params[:recreate_data]
    render :action => "list"
  end

  def chart_inline
    begin
      @chart.delete_data if params[:recreate_data]
      render :partial => 'chart'
    rescue
      render :text => "Message:<br><pre>#{$!.message}\n</pre>Trace:<br><pre>#{$!.backtrace.join("\n")}</pre>", :layout => false
    end
  end

#  def chart_image    
#    @chart.render(params[:recreate_data])
#    headers['Cache-Control'] = 'no-cache, must-revalidate'
#    send_file( @chart.png_file_name,
#	      :disposition => 'inline', 
#	      :type => 'image/png', 
#	      :filename => @chart.image_id + ".png")
#  end

  def chart_map
    @chart.render(:recreate_data => params[:recreate_data])   
    @chart_image_tag = @chart.image_tag({:url => url_for(:controller => "charts", :action => "chart_image") + "?"})
    @chart_image_map = @chart.image_map({:link => url_for(:action => "chart_click", :state_id => state_id) + "&"})
    
    render :partial => "chart_map"
  end

  def chart_data
    data = @chart.get_data
    table = Ruport::Data::Table.new(:column_names => data[0].keys.map {|k| k == "data" ? @chart.data_column : k})
    data.each {|row|
      table << data[0].keys.map {|k| row[k]}
    }
    if params[:type] == "csv"
      render :text => "<pre>#{table.to_csv}</pre>"
    else
      render :text => "<pre>#{table}</pre>"
    end
  end

  def normalize_parameter(column_param, value_param, remove_value_if_not_found = false)
    column = params.delete(column_param)
    if column.nil? or column == ""
      params.delete(value_param) if remove_value_if_not_found
      return nil 
    end

    value = params.delete(value_param)    
    if value =~ Regexp.new("^" + Regexp.quote("#{column}=") + "(.*)")
      value = $1
    end

    if value == Chart::NIL_VALUE then
      value = nil
    end
    
    if value.nil?
      operator = "IS NULL"
    else
      if value.length > 0 and value[-1,1] == "%" 
	operator = "LIKE"
      else
	operator = "="
      end
    end

    if current_table and current_table.columns_hash[column] and 
	current_table.columns_hash[column].type == :date and
	value =~ /^\d+\.?\d*$/
      value = Chart.map_to_date(value)
    end

    if current_table and current_table.columns_hash[column] and 
	current_table.columns_hash[column].type == :time and
	value =~ /^\d+\.?\d*$/
      value = Chart.map_to_time(value)
    end

    params[:columns] ||= []
    params[:operators] ||= []
    params[:values] ||= []

    params[:columns].push(column)
    params[:operators].push(operator)
    params[:values].push(value)
  end

  def chart_click
    normalize_parameter(:column, :category)
    normalize_parameter(:column1, :category)
    normalize_parameter(:category_column, :category, true)
    normalize_parameter(:column2, :series)
    normalize_parameter(:serie_column, :series, true)
    normalize_parameter(:range_column, :range)
    
    params[:action] = "add_condition"   

    clone_session
    params[:state_id] = state_id    
    redirect_to params.update(:action => "add_condition")
  end

  def auto_refresh_inline
    begin
      if params[:auto_refresh]
	if params[:auto_refresh].to_i < 1
	  params[:auto_refresh] = nil 
	  flash[:error] = "Auto refresh value must be an integer above 1."
	end
      end
      render :partial => 'auto_refresh'
    rescue
      render :text => "Message:<br><pre>#{$!.message}\n</pre>Trace:<br><pre>#{$!.backtrace.join("\n")}</pre>", :layout => false
    end   
  end
  def auto_refresh_info
    @chart.delete_data if @chart
    render :partial => "auto_refresh_info"
  end

  def create_date(param)
    param[:year] = Time.now.year if param[:year] == ""
    if param[:month] == "" and  param[:day] != "" then
      param[:month] = Time.now.month
    end
    if param[:month] != "" and param[:day] == "" then
      param[:day] = 1
    end
    return Date.civil(param[:year].to_i,param[:month].to_i,param[:day].to_i) if
      param[:year] != "" and param[:month] != "" and param[:day] != ""
  end

  def del_condition
    @conditions[params[:id].to_i..params[:id].to_i] = []
    @current_filter.set_conditions(@conditions)
    reset_paging
    save_session
    list
    render :action => 'list'
  end

  def toggle
    @conditions[params[:id].to_i][3] = !(@conditions[params[:id].to_i][3])
    @current_filter.set_conditions(@conditions)
    list
    render :action => 'list'
  end

  def only_condition
    @conditions = [@conditions[params[:id].to_i]]
    @current_filter.set_conditions(@conditions)
    list
    render :action => 'list'
  end

  def negative_set
    @negative_set = true
    list
    render :action => 'list'
  end

  def banished
    @banished_set = true
    @negative_set = true
    @global_rule_number = number = params[:id].to_i
    list
    render :action => 'list'
  end

  def negate_all_but
    @negative_set = true
    @global_rule_number = number = params[:id].to_i
    list
    render :action => 'list'

#    @conditions = Marshal.load(params[:conditions]) unless @conditions
#    number = params[:id].to_i
#    for i in 0...@conditions.length
#      if i!=number then
#        case @conditions[i][1]
#        when "IS NULL"
#          @conditions[i][1] = "NOT IS NULL"
#        when "NOT IS NULL"
#          @conditions[i][1] = "IS NULL"
#        when "LIKE"
#          @conditions[i][1] = "NOT LIKE"
#        when "NOT LIKE"
#          @conditions[i][1] = "LIKE"
#        when "="
#          @conditions[i][1] = "!="
#        when "!="
#          @conditions[i][1] = "="
#        else
#          throw "Unknown operator #{@conditions[i][1]}"
#        end
#      end
#    end
#    list
#    render :action => 'list'
  end

end
