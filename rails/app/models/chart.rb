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

  class Chart < ActiveRecord::Base
      has_and_belongs_to_many :report_templates

    # Maximum length of values in source data and
    # in charts. Values longer than this will be
    # truncated.
    MAX_VALUE_LENGTH = 50
    # Amount of time source data of charts will be cached.
    CACHING_TIMEOUT = 6 * 60 # minutes (6 hours)
    # The different types of charts
    CHART_TYPES = [:bar, :line, :pie]
    # Descriptions of chart types
    CHART_TEXTS = {
      :bar =>  "Generates a bar chart. If you select a y-axis, the bar chart will be stacked with the the values of the y-axis as stacked pieces.",
      :line => "Generates a line chart. Only the x-axis will take effect, no y-axis is allowed for this type of chart. In difference to the bar chart, the displayed range will not start from 0. The axis is adapted to the values returned from the query (min,max).",
      :pie => "Generates a pie chart. Only the x-axis will take effect, no y-axis is allowed for this type of chart."
      #TODO: :spider => "Spider Web chart"
      
    }
    # Chart option names
    CHART_OPTIONS = [:stacked, :flipped]   
    # Default width of the chart in pixel
    DEFAULT_WIDTH = 1000
    # Default height of the chart in pixel
    DEFAULT_HEIGHT = 600

    attr_accessor :datasource
    attr_accessor :zoom
    attr_accessor :mode
    
    validates_presence_of :column1,:chart_type

    # Validation of the chart
    validate do |c|
      ds = c.datasource
      if ds	
	c.errors.add("column1", "Not a valid column.") unless c.valid_column?("column1",ds, :check_type => true)
	c.errors.add("column2", "Not a valid column.") unless c.valid_column?("column2",ds, :required => false)
	c.errors.add("column3", "Not a valid column.") unless c.valid_column?("column3",ds, :required => false)
	c.errors.add("aggregation_column", "Not a valid column.") unless 
	  c.valid_column?("aggregation_column",ds, :required => false, :asterix_allowed => true)

      end

      c.errors.add("column3", "3 Dimensional pie chart not allowed") if 
	c.column3 and c.chart_type == "pie"

      begin
	if c.time_range
	  c.errors.add("time_range", "Datasource has no column 'data'.") if
	    ds and not ds.table.columns_hash["date"]
	  c.time_range.to_time_range if c.time_range
	end
      rescue
	c.errors.add("time_range",$!)
      end 
    end

    # alias for column1 (x-axis)
    def category_column; column1; end
    # alias for column2 (y-axis)
    def serie_column; column2; end
    # alias for column3 (z-axis)
    def range_column; column3; end

    # The time range of data that this chart is using.
    def time_range
      t = super
      return nil if super == ""
      t
    end

    # Return true if this type of chart can be
    # rendered out of the given datasource
    def applyable?(datasource)
      c = self.clone
      c.datasource = datasource
      return c.valid?
    end

    # Return all charts that can be rendered
    # out of the given datasource.
    def self.charts_for_datasource(ds)
      Chart.find(:all).select{|c| c.applyable?(ds)}
    end
    
    # The current datasource
    def datasource
      if @mode == :preview
	RandomDatasource.new([column1,column2,column3,"data"])
      else
	@datasource
      end
    end

    # Set the current datasource
    def datasource=(val)
      raise "view only mode enabled. Cannot set new datasource." if mode == :view_only
      @datasource = val
    end

    # Returns the current time range condition as a
    # Condition Class
    def date_condition
      Condition.create("date","DATE",time_range) if time_range
    end
    
    # Returns SQL conditions of the configured conditions in this chart.
    def conditions(options = {})
      conds = []
      conds.push(@conditions) if @conditions
      conds.push(date_condition.sql(datasource)) if date_condition
      conds.push(options[:conditions]) if options[:conditions]
      return conds.join(" AND ") if conds.length > 0
    end
    # Set new conditions. Not available if view mode is :view_only
    def conditions=(val)
      raise "view only mode enabled. Cannot set new conditions." if mode == :view_only
      @conditions = val
    end
    
    # Return wether the given column supports
    # the type of chart. Currently only needed
    # for line charts. Line charts need a
    # numerical representation of the value.
    def self.column_supports_type?(column, type)
      case type
      when "line"
	return (column.number? or column.type == :time or column.type == :date)
      else
	return true
      end
    end

    # Returns true if the field_name is (column1, column2...) contains
    # a valid column name for the given (ds) or default datasource.
    # options: :required, if field must contain a column, :asterix_allowed, if
    # the field may contain an asterix 
    def valid_column?(field_name, ds = nil, options = {})      
      name = send(field_name)
      return true if !options[:required].nil? and options[:required] == false and name.blank?

      if col = (ds or datasource).table.columns_hash[name]
	if options[:check_type] and !Chart.column_supports_type?(col, chart_type)
	  errors.add(field_name, "Column type #{col.type} is not supported for chart #{chart_type}.")
	  return false 
	end
	return true
      end
      return true if name == "*" and options[:asterix_allowed]
      errors.add(field_name,"Invalid value '#{name}'.")
      return false
    end

    # Set the data directory. Should be chart specific,
    # function delete data removes the whole directory!
    def set_data_directory(dir)
      @data_directory = dir
    end

    # Data directory, where the chart data and the chart
    # should be saved after rendering.
    def data_directory
      if @data_directory
	p = Pathname.new(@data_directory)
      else
	p = Pathname.new(RAILS_ROOT) + "tmp/charts/#{query.hash}"
      end
      p.mkpath
      p
    end

    # Removes the whole (!) data directory
    def delete_data
      d = data_directory
      d.rmtree if d.exist? and d.directory?
    end

    # Filename of the chart
    def image_name
      "#{chart_type.camelize}Chart_#{height}_#{width}.png"
    end

    # Returns the yaml hash representing the chart object
    def yaml_hash
      # access attributes that may change values
      if mode == :view_only
	@yaml_hash
      else
        super
      end
    end

    # overwriting yaml_hash for loading old charts
    def yaml_hash=(val)
      mode = :view_only
      @yaml_hash = val
    end

    # Full basename of all files (including data patch)
    def base_name; (data_directory + "chart").to_s; end
    # Long full basename with main attributes in the name (type, width, height, hash).
    def long_base_name; (data_directory + "chart_#{chart_type}_#{width}x#{height}_#{yaml_hash}").to_s; end

    # Filename where data source is stored (.data)
    def data_filename; base_name + ".data"; end
    # Filename where image file is stored (.png)
    def png_file_name; long_base_name + ".png"; end
    # Filename where the imagemap for html pages is stored (.map)
    def image_map_file_name; long_base_name + ".map";  end

    # Date (mtime of data file) of stored data
    def data_date;  File.mtime(data_filename) rescue nil; end
    # Date (mtime of image file) of stored image
    def image_date; File.mtime(png_file_name) rescue nil; end
   
    # Save yaml to the yaml file in the data directory (.yaml)
    def save_yaml
      open((base_name + "_#{yaml_hash}.yaml"),"w") {|f| f.write(self.to_yaml)}
    end
    
    # Load Chart instance from a archive path, (data_dir can also be a yaml_hash)
    def self.load_yaml(data_dir, yaml_hash)
      if data_dir.to_s.to_i == 0
        # data_dir is a real path
	data_directory = Pathname.new(data_dir)
	raise "Data '#{data_dir}' directory not found." unless data_directory.exist?
      else
        # data_dir is only a hash number, look in tmp path for it
	data_directory =  Pathname.new(RAILS_ROOT) + "tmp/charts/#{data_dir}"
      end

      unless yaml_hash
        # if no yaml hash provided, load the only one available,
        # if more charts are available, raise exception
	glob = Dir.glob((data_directory + "chart_*.yaml").to_s)
	raise "More than one chart found in directory '#{data_directory}'." if
	  glob.length > 1
	raise "No chart found in directory '#{data_directory}'." if
	  glob.length == 0
	
	glob[0] =~ /chart_(-?\d*).yaml$/
	yaml_hash = $1
	#	file = glob[0]
      end

      file = data_directory + "chart_#{yaml_hash}.yaml"

      c = Chart.from_yaml(open(file,"r") {|f| f.readlines.join})
      c.set_data_directory(data_directory)
      c.mode = :view_only
      c.yaml_hash = yaml_hash.to_i
      c.freeze
      c
    end

    # Path to alois java sourcepath
    def Chart.java_src
      Pathname.new(RAILS_ROOT + '/java/').realpath.to_s
    end
    # Java Classpath for execution
    def Chart.java_cp
      '/usr/share/java/jcommon.jar:/usr/share/java/jfreechart.jar:' + java_src
    end

    # Returns the java rendering command for render the chart, after
    # execution of this command, the chart png file will exist (if no
    # error occurred) 
    def render_command()
      raise "Deprecated: $display_environment, please remove this from your environment config (/etc/alois/environment.rb)." if $display_environment
      disp = ""
      #disp = if $display_environment then "DISPLAY=#{$display_environment} " else "" end
      
      params = { :category_column => category_column, :serie_column => serie_column, :range_column => range_column }.to_query
      
      "#{disp}/usr/bin/java -classpath \"#{Chart.java_cp}\" CreateChart '" + long_base_name + "' '<<LINK_ROOT>>#{params}'  #{chart_type} #{stacked} #{flipped}"
    end
    
    # Returns the compile command to compile the java CreateChart.java file
    def Chart.compile_command	    
      ret = nil
      cmd = "cd #{java_src}; /usr/bin/javac -nowarn -classpath \"#{java_cp}\" CreateChart.java 2>&1"
      IO.popen(cmd,"r") {|out|
	ret = out.readlines
      }
      throw "CreateChart compile error (#{cmd})\n #{ret.join("\n")}" unless $?.success?
    end

    # Chart column2, will be nil if database value is ""
    def column2
      val = super
      return nil if val == ""
      return val
    end

    # Chart column3, will be nil if database value is ""
    def column3
      val = super
      return nil if val == ""
      return val
    end
    
    # get chart data, either from file if some data has already
    # been stored on disc or a select to the previously defined
    # datasource will be called.
    def get_data(options = {})
      if File.exists?(data_filename) and not options[:recreate_data]
	data = YAML::load(File.open(data_filename))
      else
	ds = (options[:datasource] || datasource)
	if ds.respond_to?(:data)
	  data = ds.data
	else
	  data = ds.table.connection.select_all(query(options))
	end
	File.open(data_filename, 'w') { |f| f.puts data.to_yaml }
      end
      data
    end

    # Return cvs values of data (See get_data). For this, ruport
    # is used
    def to_csv
      d = get_data
      return "Sorry, no records." if d.length == 0
      arr = []
      d.each {|row| arr.push(row.dup)}
      tbl = Ruport::Data::Table.new(:column_names => arr[0].keys)
      arr.each {|row|
	tbl << arr[0].keys.map {|k| row[k]}
      }
      
      return tbl.to_csv
    end

    # Maximum amount of different values to display in
    # chart. If maximum reached, the other values will be
    # grouped into a separate value called REST
    def max_values
      if chart_type == "line"
	return -1
      else
	super
      end
    end

    # TODO: add comment
    def guess_and_expand_names(names)
      return names if names.length == 0 or names.compact.length != names.length
      # check if these are dates and have correct order
      if names.select {|n| n =~ /^\d\d\d\d-\d\d-\d\d$/}.length == names.length and
	  names.sort == names and
	  names[0].to_time < names[-1].to_time and
	  ((names[-1].to_time - names[0].to_time) / 1.day).to_i.abs <= max_values
	new_names = (names[0].to_date..names[-1].to_date).to_a.map{|d| d.strftime("%F")}
      end
      if names.select {|n| n =~ /^\d+$/}.length == names.length and
	  names.sort {|x,y| x.to_i <=> y.to_i} == names and 
	  names[0].to_i < names[-1].to_i and
	  (names[-1].to_i - names[0].to_i).abs <= max_values
	new_names = (names[0].to_i..names[-1].to_i).to_a.map{|d| d.to_s}
      end
      return names unless new_names
      return new_names.map {|nn| if names.include?(nn) then nn else nn + "*" end }
    end

    # TODO: add comment
    def traverse_table(table, names_arr, aggregation_columns, data_column, sum = false)
      ret = {}
      if names_arr.length > 0
	names_arr[0].each {|name|
	  ret[name] = traverse_table(table.select{|r| r[aggregation_columns[0]] == name},
				      names_arr[1..-1],
				     aggregation_columns[1..-1],
				     data_column)
	}

	# if there are any records left, add them as rest
	rest_table = table.reject{|r| names_arr[0].include?(r[aggregation_columns[0]])}
	if rest_table.length > 0
	  ret[REST_VALUE] = traverse_table(rest_table,
				       names_arr[1..-1],
				       aggregation_columns[1..-1],
				       data_column,true)
	  names_arr[0].push(REST_VALUE)
	end
      else
	return 0 if table.length == 0
	if true
	  return table.map {|r|r[data_column].to_i}.sum
	else
	  throw "more than one value left" if table.length > 1
	  return table[0][data_column].to_i
	end
      end
      return ret
    end

    # TODO: add comment
    def transform_table(table, aggregation_columns, data_column)
      names =[]
      aggregation_columns.each {|col|
	names.push(table.map {|row| row[col]}.uniq[0..max_values])
      }
      return names, traverse_table(table, names, aggregation_columns, data_column)
    end

    # Placeholder for nil values
    NIL_VALUE = "<<NULL>>"
    # Placeholder for rest value
    REST_VALUE = "<<REST>>"

    # write value to the pipes and replace
    # nil value with placeholder (See NIL_VALUE)
    def my_write(pipes, value)
      pipes.write("#{(value || NIL_VALUE).to_s.strip.gsub(/\n|\r/,"")}\n")
    end

    # Map value to number (used for line charts
    # eg. date and times can be displayed as
    # a float). In later versions the java class
    # for date and times should be used.
    def self.map_to_number(val)
      case val
      when /(\d\d):(\d\d):(\d\d)/
	hour = $1.to_f
	hour += $2.to_f / 60.0
	hour += $3.to_f / 60.0 / 60.0
	return "#{hour}"
      when /(\d\d\d\d)-(\d\d)-(\d\d)/	
	cur = (DateTime.parse("#{$1}-#{$2}-#{$3}") - DateTime.parse("#{$1}-01-01")).to_i
	tot = (DateTime.parse("#{$1.to_i + 1}-01-01") - DateTime.parse("#{$1}-01-01")).to_i
	return ("%.3f" % ($1.to_f + cur.to_f / tot.to_f))
#      when /(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)/
#	year = $1.to_i
#	year += $2.to_f / 12.0
#	year += $3.to_f / 12.0 / 31.0
#	year = $4.to_i / 365.0
#	year += $5.to_f / 365.0 / 60.0
#	year += $6.to_f / 365.0 / 60.0 / 60.0
#	return "#{year}"
        #      end
      else
        val.to_f
      end
    end

    # remap a integer value to a date (See map_to_number)
    def self.map_to_date(value)
      year = value.to_i
      tot = (DateTime.parse("#{year + 1}-01-01") - DateTime.parse("#{year}-01-01")).to_i
      day = ((value.to_f - year.to_f) * tot.to_f).round
      (DateTime.parse("#{year}-01-01") + day).strftime("%F")
    end

    # remap a float value to a time (See map_to_number)
    def self.map_to_time(value)
      value = value.to_f
      hour = value.to_i
      value = (value - hour.to_f) * 60.0
      minute = value.to_i
      second = ((value - minute.to_f) * 60.0).round
      value = "#{hour.to_s.rjust(2,"0")}:#{minute.to_s.rjust(2,"0")}:#{second.to_s.rjust(2,"0")}"
    end

    # Render this configured chart into png, html and imagemap.
    # If a up to date version is available, render will do nothing.
    # See also CACHING_TIMEOUT
    def render(options = {})
      # Do nothing if chart has already been rendered and
      # caching timeout has not been reached yet
      return if File.exist?(png_file_name) and File.exists?(image_map_file_name) and not (image_date < data_date rescue false) and not options[:recreate_data] and not (data_date > CACHING_TIMEOUT.minutes.ago and mode != :view_only)

      # View only charts are loaded from a directory, they should
      # already be rendered.
      raise "Cannot render, viewing only!" if mode == :view_only

      # Store values in chart attributes for later serialization
      @table_name = (options[:datasource] || datasource).table.table_name
      @option_conditions = options[:conditions]

      # external link will be used for imagemap
      @external_link  = "#{$root_url}table/#{@table_name}/chart_click?" +
	{:default_filter => conditions(options)}.to_query + "&"

      # save the created information into yaml, so nothing
      # can be changed later.
      save_yaml
      $log.debug{"Getting data for chart."}
      # Query or load data for chart
      result = get_data(options)

      $log.debug{"Prepare data for chart."}
      if chart_type == "line"
        # Map values to numbers for that a line can be rendered
	result.each {|row|
	  row[category_column] = Chart.map_to_number(row[category_column])
	}
      end
      
      # Compile java application if we are working in
      # a develepment environment.
      Chart.compile_command if RAILS_ENV == 'development'
      cmd = "#{render_command()} 2>&1 > '#{long_base_name}.err'"

      # aggregation columns
      agg_cols = [column3,column2,column1]

      # TODO: Comment this function till the end
      all_names, tree = transform_table(result, agg_cols, "data")
      if chart_type != "lines" and chart_type != "line"
	all_names = all_names.map {|n| guess_and_expand_names(n) }
      end

      category_names = all_names[2]
      serie_names = all_names[1]
      range_names = all_names[0]

      begin
	#	Timeout.timeout(10){	
	$log.debug{"Sending data to java app."}
	
	IO.popen(cmd,"w") {|pipes|

	  my_write(pipes,"#{category_column.pluralize.humanize} from #{datasource.name}" + if conditions(options) then " WHERE #{conditions(options)}" else "" end)
	  my_write(pipes,"#{width}")
	  my_write(pipes,"#{height}")
 	  
	  # xaxis
	  my_write(pipes, category_column)
	  # yaxis
	  my_write(pipes, data_column)
	  
	  # series	  
	  my_write(pipes, serie_names.length)
	  
	  # ranges
	  my_write(pipes, range_names.length)
	  
	  range_names.each {|range|
	    if range_column.nil?
	      my_write(pipes, nil)
	    else
	      if range == REST_VALUE
		my_write(pipes, range)
	      else
		my_write(pipes,"#{range_column}=#{range or NIL_VALUE}")
	      end
	    end
	    
	    serie_names.each {|serie|
	      if serie_column.nil?
		my_write(pipes, nil)
	      else
		if serie == REST_VALUE
		  my_write(pipes, serie)
		else
		  my_write(pipes,"#{serie_column}=#{serie or NIL_VALUE}")
		end
	      end
	      
	      my_write(pipes, category_names.length)
	      my_write(pipes, 1)
	      
	      category_names.each {|name| 
		if name and name.to_s.length >= MAX_VALUE_LENGTH
		  my_write(pipes,"#{name}%")
		else
		  my_write(pipes, name)
		end
		my_write(pipes,(((tree[range] or {})[serie] or {})[name] or 0))
	      }
	    }
	  }
	  $log.debug{"Closing java pipes."}
	  pipes.close
	  $log.debug{"Java render done."}
	}

	unless $?.success?
	  ret = nil
	  open(long_base_name + ".err") {|f| ret = f.readlines.join("\n")} if File.exist?(long_base_name + ".err")
	  throw "Image render failed (#{cmd}).\n #{ret}" 
	end

	# correct bug that the category begins always with a '?'
	map = open(image_map_file_name).readlines.join
	map.gsub!("?category=","&category=")
	map.gsub!("?series=","&series=")
	open(image_map_file_name,"w") {|f| f.write(map)}

      rescue Timeout::Error
	msg = open(long_base_name + ".err").readlines.join("\n")
	Dir.glob(long_base_name + ".*").each {|f|
	  File.delete(f)
	}
	
	throw "Generating graphic failed.\n#{msg}"
      end

    end

    # Construct the image_tag string for this chart (displayed on mouseover)
    def image_tag(options = {})      
      real_file = (Pathname.pwd + png_file_name).realpath.to_s
      if options[:url]
	params = {:action => "chart_image",
	  :chart_yaml_hash => yaml_hash}
	if @data_directory
	  params[:chart_data_dir] = @data_directory.to_s
	else
	  params[:chart_tmpdir_hash] = query.hash.to_s
	end
	url = options[:url] + "&" + params.to_query
      end
      
      if options[:relative_path]
	relative_path = Pathname.new(options[:relative_path]).realpath.to_s
	
	if real_file =~ Regexp.new("^#{Regexp.escape(relative_path + "/")}(.*)$")
	  url = $1
	else
	  raise "'#{real_file}' is no subpath of '#{relative_path}'."
	end
      end
      
      if options[:absolute_path]
	url = real_file	
      end

      mapname = "#chart"
      mapname += options[:chart_number].to_s if options[:chart_number]

      "<IMG SRC=\"#{url}\" WIDTH=\"#{width}\" HEIGHT=\"#{height}\" BORDER=\"0\" USEMAP=\"#{mapname}\">"
    end

    # Image map text to be included into HTML
    def image_map(options = {})
      map = open(image_map_file_name).readlines.join("\n")
      map.gsub!('id="chart"',"id=\"chart#{options[:chart_number]}\"") if options[:chart_number]
      map.gsub!('name="chart"',"name=\"chart#{options[:chart_number]}\"") if options[:chart_number]
      map.gsub!("<<LINK_ROOT>>",(options[:link] or @external_link))
      map
    end
        
    # The aggregation value to be used. Default
    # value * has no special function (normal group by)
    # See also AGGREGATION_FUNCTIONS
    def aggregation_column
      super or "*"
    end

    # Selected chart type See CHART_TYPES
    def chart_type
      (super or "bar").singularize
    end

    # Returns supported aggregation fuctions
    AGGREGATION_FUNCTIONS = ["COUNT","SUM","MIN","MAX"]

    # Selected aggregation function
    def aggregation_function
      super or "COUNT"
    end
    
    # Combined data_column from aggregation_function and aggregation_column
    # Default value would be COUNT(*). Or other values could be: SUM(size), MIN(start_time)
    def data_column
      "#{aggregation_function}(#{aggregation_column})"
    end

    # Returns a list of possible orders for the data to be displayed
    # in the chart. Enumeration for selectbox with different combinations
    # of aggregation_columns and aggregation_functions
    def possible_orders
      if datasource
	orders = []

	AGGREGATION_FUNCTIONS.each {|agg|
	  orders.push("#{agg}(*)")
	  orders.push("#{agg}(*) DESC")	    
	}

	datasource.table.columns.each {|col1|
	  orders.push("#{col1.name}")
	  orders.push("#{col1.name} DESC")	  
	  AGGREGATION_FUNCTIONS.each {|agg|
	    orders.push("#{agg}(#{col1.name})")
	    orders.push("#{agg}(#{col1.name}) DESC")
	  }
	}

	orders.push(self.real_order_by) unless orders.include?(self.real_order_by)

	return orders.sort
      else
	raise "No datasource defined."
      end
    end

    # possilbe names for ordering
    ORDER_NAMES = ["column1","data_column","column2","column3"]

    # Return the correct column_name (column1, data_column...)
    # out of the order_by statement
    def order_by_column(number)
      col = (order_by.split(",")[number] or "").strip
      return "none" if col == ""
      
      ORDER_NAMES.each {|c|
	return c if self.send(c) == col
	return "#{c}_desc" if "#{self.send(c)} DESC" == col
      }
      return "none"
    end

    # Set a order by column
    def set_order_by_column(number, column)
      return if column == ""      
     
      desc = false
      if column =~ /^(.*)_desc$/
	column = $1
	desc = true
      end

      if ORDER_NAMES.include?(column)
	val = self.send(column)
	val = "#{val} DESC" if desc 
      else
	val = column
      end
      
      orders = order_by.split(",") #.map {|o| 
#	if o =~ /^\s*(\w+)(\s+DESC)?\s*$/i
#	  $1
#	else
#	  throw "unrecognized order '#{o}'"
#	end
#      }
#      p [orders, number, column, val]

      if orders.length >= (number + 1)
	orders[number] = val
      end
      if orders.length == number
	orders.push(val);
      end
      self["order_by"] = orders.join(",")
    end

    # TODO: this should be reworked
    def order_1st
      order_by_column(0)
    end
    # TODO: this should be reworked
    def order_1st=(val)
      set_order_by_column(0,val)
    end    
    # TODO: this should be reworked
    def order_field_1st; order_by.split(",")[0] end
    # TODO: this should be reworked
    def order_field_1st=(val); self.order_1st = val if self.order_1st == "none"; end

    # TODO: this should be reworked
    def order_2nd
      order_by_column(1)
    end
    # TODO: this should be reworked
    def order_2nd=(val)
      set_order_by_column(1,val)
    end
    # TODO: this should be reworked
    def order_field_2nd;  order_by.split(",")[1] end
    # TODO: this should be reworked
    def order_field_2nd=(val); self.order_2nd = val if self.order_2nd == "none"; end

    # TODO: this should be reworked
    def order_3rd
      order_by_column(2)
    end
    # TODO: this should be reworked
    def order_3rd=(val)
      set_order_by_column(2,val)
    end
    # TODO: this should be reworked
    def order_field_3rd;  order_by.split(",")[2] end
    # TODO: this should be reworked
    def order_field_3rd=(val); self.order_3rd = val if self.order_3rd == "none"; end

    # Return order_by of the database or
    # generate a menfull default.
    def order_by
      s = super
      s = nil if super == ""
      s or
	if column2
	  "#{column1}, #{column2}"
	else
	  "#{data_column} DESC"
	end
    end
    
    # returns a SQL usabel order by statement
    def real_order_by
      order_by.split(",").reject {|o| o == "none"}.join(",")
    end

    # Generate a SQL statement to get data for rendering this chart
    def query(options = {})

      col = datasource.table.columns.select{|s| s.name ==column1}[0]
      r = ""
      if col.type == :string or col.type == :binary
	r += "SELECT substr(#{column1},1,#{MAX_VALUE_LENGTH}) as #{column1}"
      else
	r += "SELECT #{column1}"
      end	
      r += ", #{column2}" if column2
      r += ", #{column3}" if column3
      r += ", #{data_column}"
      r += " AS data FROM "
      if datasource.table.respond_to?(:override_query) and 
	  (m_query = datasource.table.override_query(:conditions => conditions(options)))
	r += "(#{m_query}) AS mod_query"
      else
	r += "#{datasource.table.table_name}"
      end
      r += " WHERE #{conditions(options)}" if conditions(options)
      r += " GROUP BY "
      r += "#{column3}, " if column3
      r += "#{column2}, " if column2
      r += "#{column1} ORDER BY " + real_order_by
      return r
    end

#    def max_bars=(val)
#      @max_bars = val.to_i
#    end
#    def max_bars
#      return @max_bars if @max_bars
#      m = (width / 22)
#      m = m / 2 if column2
#      return m.to_i
#    end

    # get zoom (1.0 is no zoom with defined height and weight)
    def zoom
      (((@zoom or 1).to_f * 100).round)/100.0
    end
    # set zoom (1.0 is no zoom with defined height and weight)
    def zoom=(value)
      @zoom = value
    end

    # Default width for image rendering in pixel (with zoom 1.0)
    def width
      self["width"] = DEFAULT_WIDTH unless super
      w = super
      w = (w * zoom).to_i if zoom
      w	
    end

    # Default height for image rendering in pixel (with zoom 1.0)
    def height
      self["height"] = DEFAULT_HEIGHT unless super
      h = super
      h = (h * zoom).to_i if zoom      
      h	
    end

    ### Ossim stuff, deprecated?

    CUSTOM_GRAPH = "/../ossim/panel/custom_graph.php"

    def image_url_params
      {:controller => CUSTOM_GRAPH, :params => ossim_params}
    end

  end
