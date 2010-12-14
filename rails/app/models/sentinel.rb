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

  class Sentinel < ActiveRecord::Base
    has_many :alarms
    has_many :reports
    
    belongs_to :report_template
    belongs_to :view

    CRONTAB_REGEX = /([0-5]?[0-9]|\*) ([0-1]?[0-9]|2[0-4]|\*) (\d*|\*) (\d*|\*) (\d*|\*)/ 
    ACTIONS = {
      0 => :disabled,
      1 => :report,
      2 => :alarm,
      3 => :alarm_and_report}

    validates_presence_of :name, :threshold, :view
    validates_uniqueness_of :name
    validates_format_of :cron_interval, :with => CRONTAB_REGEX

    validate do |s|
      if s.action_name == :report or s.action_name == :alarm_and_report
	s.errors.add("action", "Please specify a report_template for action '#{s.action_name}'") unless 
	  s.report_template
      end
      if s.time_range and s.time_range != "" and s.view
	begin
	  s.date_condition.validate(s.view)
	rescue
	  s.errors.add("time_range",$!)
	end
      end

      if s.view
	begin
	  s.filters.each {|f|
	    s.errors.add("filters", "Filter #{f.id} is not applicable for view #{s.view.id}") unless
	      f.valid_for_table?(s.view)
	  }
	  s.conditions
	rescue
	  s.errors.add("Error building conditions: #{$!}")
	end
      end
    end

    # hm, otherwise test fails: ruby test/functional/sentinels_controller_test.rb --name test_load_yaml
    def include_csv_in_email; include_csv_in_email? rescue include_csv_in_email; end
    def include_report_in_email; include_report_in_email? rescue include_report_in_email; end

    def date_condition
      Condition.create("date","DATE",time_range) if time_range and time_range != ""
    end

    def filters
      Filter.parse_text_field(self["filters"])
    end

    def filters=(val)
      remove_instance_variable("@count") if
	  instance_variable_defined?("@count")
      super
    end

    def conditions(options = {})
      options[:table_class] ||= view
      options[:table_class] = nil if options[:table_class] and options[:table_class].do_not_use_view_for_query
      c = ([date_condition] + filters).compact.map {|f| f.sql(options)}.join(" AND ")
      return nil if c.strip == ""
      c
    end
    
    ## To use this add the following line into the sudoers file
    # www-data        ALL=(prisma)    NOPASSWD:/usr/bin/alois-sentinel --generate-crontab
    if RAILS_ENV == 'production'
      UPDATE_COMMAND = "/usr/bin/sudo -S -p '' -u prisma /usr/bin/alois-sentinel --generate-crontab < /dev/null"
    else
      UPDATE_COMMAND = RAILS_ROOT + "/script/sentinel --list-crontab > /dev/null"      
    end
    def update_cron
      errors.add_to_base("Error while updating crontab (#{UPDATE_COMMAND}).") unless system("#{UPDATE_COMMAND}")
    end

    def save
      ret = super
      update_cron
      ret
    end

    def destroy
      update_cron
      super
    end
    
    def enabled
      action != ACTIONS.invert[:disabled]
    end

    def count
      return @count if defined?(@count)
      raise "No view defined." unless view
      view.create_view
      @count = view.table.count(:conditions => conditions)
    end    
    
    def time_range=(val)
      remove_instance_variable("@count") if
	  instance_variable_defined?("@count")
      super
    end
    
    def is_alarm?
	threshold < count
    end
    
    def action_name
      ACTIONS[self.action]
    end

    def action=(val)
      if val.is_a?(Symbol)
	"Action '#{val}' not found." unless ACTIONS.value?(val)
	val = ACTIONS.invert[val]	
      end
      super(val)
    end

    def alarm_level_color
      Alarm::ALARM_COLORS[self.alarm_level]
    end

    def alarm_level_name
      Alarm::ALARM_LEVELS[self.alarm_level]
    end

    def alarm_level=(val)
      if val.is_a?(Symbol)
	"Alarm '#{val}' not found." unless Alarm::ALARM_LEVELS.value?(val)
	val = Alarm::ALARM_LEVELS.invert[val]	
      end
      super(val)
    end
    
    def datasource
      view
    end
            
    def process
      raise "This sentinel is disabled." if action_name == :disabled

      $log.debug "Processing sentinel.#{self.id}." if $log.debug?
      alarm = nil
      report = nil
      @process_errors = []
      options = { :conditions => conditions, :datasource => view  }
      if is_alarm?
	$log.debug "Sentinel claim it's an alarm." if $log.debug?
	
	if action_name == :report or action_name == :alarm_and_report
	  begin
	    rt = report_template	    
	    $log.info("Generating report.")
	    report = Report.generate(rt, self, options)
	    $log.info("Generated report has id #{report.id}.")
	  rescue
	    $log.error("Error generating report: '#{$!}'")
	    @process_errors.push($!)
	  end
	end
      

	if action_name == :alarm or action_name == :alarm_and_report
	  begin
	    alarm = Alarm.generate(self, report, options)
	  rescue
	    $log.error("Error generating alarm: '#{$!}'")
	    @process_errors.push($!)
	  end
	end
	
	
	if send_mail
	  begin
	    $log.info("Sending mails to '#{self.mail_to.inspect}'.")

	    if alarm
	      AlarmMailer.deliver_simple(self.mail_to, alarm)
	    end
	    if report
		if self.include_report_in_email
		  ReportMailer.deliver_normal(self.mail_to, report, {:add_csv => self.include_csv_in_email})
		else
		  ReportMailer.deliver_simple(self.mail_to, report, {:add_csv => self.include_csv_in_email})
		end
	    end

	    $log.info("Mails sucessfully sent.")
	  rescue
	    $log.error("Error sending mail: '#{$!}'")
	    @process_errors.push($!)
	  end	
	end
      end

      if @process_errors.length > 0
	# send error mail
	BaseMailer.send_exception(@process_errors)
      else
	@process_errors = nil
      end

      [alarm,report]
    end

    def process_errors
      return nil if @process_errors.nil?
      return @process_errors
    end
    

    def text
throw "Deprecated function"
      return @text if @text
      total = self.view.table.count

      ret = "#{self.name}\n"
      ret += "-" * self.name.length + "\n\n"
      ret += "#{self.description}\n\n\n"
      if total > RECORD_LIMIT 
	ret += "DATATABLE (top #{RECORD_LIMIT} of #{total} records):\n"
      else
	ret += "DATATABLE (#{total} records):\n"
      end

      begin
	@data = view.table.report_table(:all, :limit => RECORD_LIMIT)
	txt = @data.as(:text, :ignore_table_width => true)
	txt = "#{ret[0..MAX_TEXT_LENGTH]}\n.... (truncated) ...\n" if 
	  ret.length > MAX_TEXT_LENGTH
      rescue
	txt = "ERROR GENERATING TABLE\n#{$!.inspect}"
      end
      @text = ret + txt
      return @text

    end
    
  end

