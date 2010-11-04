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

class Alarm < ActiveRecord::Base
  belongs_to :sentinel
  has_one :report

  # Levels from syslog:
  #  0 Emergency : system is unusable 
  #  1 Alert: action must be taken immediately 
  #  2 Critical: critical conditions 
  #  3 Error: error conditions 
  #  4 Warning: warning conditions 
  #  5 Notice: normal but significant condition 
  #  6 Informational: informational messages 
  #  7 Debug: debug-level messages
  ALARM_LEVELS = {
    0 => :emergency, 
    1 => :alert, 
    2 => :critical,
    3 => :error,
    4 => :warning,
    5 => :notice,
    6 => :informational,
    7 => :debug }

  # Define a color for every alarm level
  ALARM_COLORS = {
    0 => "red",
    1 => "red", 
    2 => "red",
    3 => "orange",
    4 => "yellow",
    5 => "grey",
    6 => "green",
    7 => "transparent" }  
  
  # Alarm states for alarm workflow
  PROCESS_STATES = {
    0 => :new,
    1 => :assigned,
    2 => :in_progress,
    10 => :closed
  }

  # SQL Array of Alarm levels to use in SQL queries
  def self.sql_array(levels)
    inv = Alarm::ALARM_LEVELS.invert	
    "(" + levels.map{|l| inv[l]}.join(",") + ")"
  end

  # SQL Condition for alarms that are not acknowledget yet
  NOT_ACKNOWLEDGE_CONDITION = "(process_state < 10 or process_state IS NULL)"
  # SQL Condition for alarms that has already been acknowledged
  ACKNOWLEDGE_CONDITION = "process_state = 10"

  # Levels that need immediate attention
  RED_LEVELS = [:emergency, :alert, :critical]
  # SQL Condition for alamrs that need immediate attention
  ACTIVE_RED_CONDITION = "#{NOT_ACKNOWLEDGE_CONDITION} AND alarm_level IN #{sql_array(RED_LEVELS)}"

  # Levels that need attention, but not immediately
  YELLOW_LEVELS = [:error, :warning]
  # SQL Condition for alamrs that need attention but not immediately
  ACTIVE_YELLOW_CONDITION =  "#{NOT_ACKNOWLEDGE_CONDITION} AND alarm_level IN #{sql_array(YELLOW_LEVELS)}"

  # SQL Condition for alarms that need acknowledge
  ACTIVE_YELLOW_RED_CONDITION = "#{NOT_ACKNOWLEDGE_CONDITION} AND alarm_level IN #{sql_array(YELLOW_LEVELS + RED_LEVELS)}"

  # Levels for informational usage
  WHITE_LEVELS = ALARM_LEVELS.values.reject {|l| RED_LEVELS.include?(l) or YELLOW_LEVELS.include?(l)}
  # SQL Condition for informational alamrs
  ACTIVE_WHITE_CONDITION = "#{NOT_ACKNOWLEDGE_CONDITION} AND (alarm_level IN #{sql_array(WHITE_LEVELS)} OR alarm_level IS NULL)"

  # true if alarm has been acknowledgetd already
  def acknowledge; process_state == :closed; end

  # Returns the color of the current system state,
  # if there exist a red alarm, the stat is red,
  # if there exist no red alarm but a yellow alarm
  # yellow, green otherwise.
  def self.status_color
    a = Alarm.find(:first, :conditions => ACTIVE_YELLOW_RED_CONDITION, :order => "alarm_level")
    if a then a.color else "green" end
  end

  # Returns the symbol of alarm state: :new, :assigned, ...
  def process_state
    PROCESS_STATES[super] or :unknown
  end

  # Returns the symbol of the alarm_level. See ALARM_LEVELS
  def alarm_level_name
    Alarm::ALARM_LEVELS[self.alarm_level]
  end
  
  # Returns the color name of the alarm based on the alarm_level
  def color
    Alarm::ALARM_COLORS[self.alarm_level]
  end

  # Sets a new alarm_level. Can either be a symbol (see ALARM_LEVELS) or
  # the integer that representes the level in the DB.
  def alarm_level=(val)
    if val.is_a?(Symbol)
      "Alarm '#{val}' not found." unless Alarm::ALARM_LEVELS.value?(val)
	val = Alarm::ALARM_LEVELS.invert[val]	
    end
    super(val)
  end 

  # Appends a message to the alarm log, the message should
  # not include datetime since the function prepends this
  # information.
  def log_message(msg, sender = nil)
    self.log ||= ""
    if sender
      self.log += "#{DateTime.now.strftime("%F %T")} #{sender.class.name}.#{sender.id}: #{msg.inspect}\n"
    else
      self.log += "#{DateTime.now.strftime("%F %T")}: #{msg.inspect}\n"
    end
    self.save
  end
  
  # Generate/Create a new alarm out of a sentinel
  def self.generate(sentinel, report,options = {})
    a = Alarm.new
    begin
      a.sentinel = sentinel
      datasource = options[:datasource]
      a.log_message("Alarm created with sentinel threashold #{sentinel.threshold}" +
		    " and count of table #{datasource.table.table_name} is #{sentinel.count}.")
      a.log_message("Saving table data.")
      
      # this does not work with big datarecords, disabled
      a.save_data(datasource,options)
      
      a.report = report

      a.alarm_level = sentinel.alarm_level
      a.save
    rescue
      a.log_message("ERROR Generating alarm: '#{$!}').")
      a.log_message($!.backtrace)
    end
    return a
  end

  # Return conditions of sentinel with the current time of the alarm
  def conditions
    self.sentinel.dup.conditions({:now => self.created_at})
  end

  # Other name for data function, see data
  def datasource; data;  end
  
  # Returns the data of that alarm
  def data
    return @data if defined?(@data)
    @data = YAML.parse(open(data_file,"r") {|f| f.readlines.reject{|r| r =~ /BigDecimal/}.join}).transform    
  end
  
  # Return the data as readable text
  def text
    if data.class == String
      return data
    else
      return data.as(:text, :ignore_table_width => true)      
    end
  end

  ##### Things for archivating ####

  # Limit of source records (query result of the sentinel that
  # causes the alarm) that will be saved in a alarm.
  RECORD_LIMIT = 1000

  # Substitutes archive path patterns
  def self.archive_path(path, conditions)
    if conditions[:id]
      path = path.gsub(/\%i/, conditions[:id].to_s)
    end
    if conditions[:date]
      path = path.gsub(/\%d/, conditions[:date].to_s)
    end
    if conditions[:time]
      path = path.gsub(/\%t/, conditions[:time].to_s)
    end
    if conditions[:name]
      path = path.gsub(/\%n/, conditions[:name].to_s)
    end
    path
  end

  # Get the path where the alarm will be archivated to.
  def path
    unless super
      # to get an id
      save if new_record?
      self.path = Pathname.new(Alarm.archive_path($alarm_archive_pattern, {
					       :date => (self.created_at.strftime("%F") rescue DateTime.now.strftime("%F")),
					       :time => (self.created_at.strfiime("%T") rescue ""),
					       :id => self.id})).to_s

      save
    end
    super
  end

  # Returns the path of the data file in the archive
  def data_file
    (Pathname.new(path) + "alarm.data").to_s
  end

  # Save data from the datasource to the correct plcae
  # in the archive
  def save_data(datasource,options = {})
    @data = datasource
    
    if @data.respond_to?(:table) and @data.table.respond_to?(:report_table)
      my_data = @data.table.report_table(:all, 
					 :limit => RECORD_LIMIT, 
					 :conditions => options[:conditions],
					 :methods => "original_text"
					 )
      log_message("WARNING: Record limit of #{RECORD_LIMIT} reached small for count. " +
		  "Not all data will be saved!",self) if
	my_data.length >= RECORD_LIMIT
    else
      my_data = @data
    end

    p = Pathname.new(path)
    p.mkpath unless p.exist?
    open(data_file,"w") {|f| f.write(my_data.to_yaml) }

    self.save
  end
  
end
