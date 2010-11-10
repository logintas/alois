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

class PrismaController < ApplicationController
  
  MUNIN_DB_PATH = "/var/lib/munin/localdomain" unless defined?(MUNIN_DB_PATH)
  STAT_NAMES = ['pumpy_count','pumpy_out','pumpy_queue','pumpy_in','alois_in','alarms_today', 'reports_today'] unless defined?(STAT_NAMES)

  def PrismaController.init
    alois_connection = Connection.from_name("alois")
    prisma_connection = Connection.from_name("prisma")
    pumpy_connection = Connection.from_name("pumpy")

    dobby = (prisma_connection and prisma_connection.spec[:host]) or "localhost"
    dobby = "localhost.localdomain" if dobby == "localhost"

    reporter = open("|hostname -f") {|f| f.readlines.join.strip}
    # reporter = (alois_connection and alois_connection.spec[:host]) or "localhost"
    # reporter = "localhost.localdomain" if reporter == "localhost"

    sink = (pumpy_connection and pumpy_connection.spec[:host]) or "localhost"
    sink = "localhost.localdomain" if sink == "localhost"
=begin
    config = read_config
    dobby = config["alois"]["host"]
    dobby = "localhost.localdomain" if dobby == "localhost"
    reporter = config["reporter"]["host"]
    reporter = "localhost.localdomain" if reporter == "localhost"
    raise "Please define attribute 'host' for the reporter host in alois.conf." if reporter.nil? or reporter.strip == ""
    sink = config["pumpy"]["host"]
    sink = "localhost.localdomain" if sink == "localhost"
=end
    
    if RAILS_ENV != "production"
      pref = "http://localhost/"
    else
      pref = "/"
    end
    
    statistic_items = [
      {:name => "sink_flows", :link_prefix => "#{pref}munin/localdomain/#{reporter}-alois_sinkflows", :desc => "Sink Flows"},
      {:name => "sink_queues", :link_prefix => "#{pref}munin/localdomain/#{reporter}-alois_sinkdb", :desc => "Sink Queues"},
      {:name => "prismas", :link_prefix => "#{pref}munin/localdomain/#{reporter}-alois_aloisdb", :desc => "Prismas"}    ]
    return [dobby,reporter,sink,statistic_items]
  end

  def init
    @dobby,@reporter,@sink,@statistic_items = PrismaController.init
  end

  def PrismaController.statistic_image(name,interval)
    dobby,reporter,sink,statistic_items = init
    statistic = statistic_items.select{|s| s[:name] == name}[0]
    throw "Statistic with name '#{name}' not found." unless statistic
    interval = interval
    throw "No interval defined." unless interval
    return "<a href=\"#{statistic[:link_prefix]}.html\"><img src=\"#{statistic[:link_prefix]}-#{interval}.png\" alt=\"#{statistic[:desc]} #{interval}\" />"
  end

  def index
    redirect_to :action => "overview"
  end

  def statistics
    init
  end
  
  def statistic
    init
  end

  def overview
    init()
    render :template => "prisma/overview-#{params[:installation_schema] or $installation_schema}"
  end

  def databases
    @connections = Connection.connections.values
  end

  def kill_query
    @connection = Connection.connections[params[:connection_name]]
    throw "Connection with name #{params[:connection_name]} not found." unless @connection
    @connection.kill(params[:id].to_i)
    sleep 1
    flash[:info] = "Killed query '#{params[:id]}'"    
    redirect_to :action => "databases"
  rescue
    flash[:error] = "Query with id '#{params[:id]}' not killed: #{$!}"
    redirect_to :action => "databases"
  end

#  def guess_host(host)
#    files = Pathname.glob("#{MUNIN_DB_PATH}/#{host}*.rrd")
#    files = files.sort { |x,y| -(File.new(x).mtime <=> File.new(y).mtime)}
#    for file in files
#      if Pathname.new(file).split()[1].to_s =~ /^([^\-]*)\-.*$/
#        return $1
#      end
#    end
#    return nil
#  end
#require 'pathname'
#  MUNIN_DB_PATH = "/var/lib/munin/localdomain"

  def read_rrd(host, stat, value, last = false)
    return 0 if RAILS_ENV != "production"
    host = "*" unless host
    files = Pathname.glob("#{MUNIN_DB_PATH}/#{host}-#{stat}-#{value}*.rrd")
    files = files.sort { |x,y| -(File.new(x).mtime <=> File.new(y).mtime)}
    
    for file in files
      begin
        if last then
	  open("|rrdtool last #{file}"){|f|
	    for line in f
	      return line.strip.to_f
	    end
	  }
        else
	  open("|rrdtool fetch #{file} AVERAGE -s -300 -e -300") {|f|
	    for line in f
	      if line =~ /^(\d*): (.*)$/
		return $2.to_f
	      end
	    end
	  }
        end
      rescue
      end
    end

    throw "Could not read rrd #{host}/#{stat}/#{value}."
  end 

  def measure(type)
    begin
      title = "Msg/s"
      result = "??"
      case type
      when "pumpy_in"
        link = "/munin/localdomain/#{@sink}-alois_sink.html"
        result = read_rrd(@sink, "alois_sink", "log_input_count")
      
      when "alois_in"
        link = "/munin/localdomain/#{@reporter}-alois_aloisdb.html"
        result = 0
        for klass in Prisma::Database.get_classes(:meta) << Message
          result = result + read_rrd(@reporter, "alois_aloisdb", "#{klass.table_name}")
        end
      
      when "pumpy_queue"
        link = "/munin/localdomain/#{@reporter}-alois_sinkdb.html"
        title = "% Full"
        result = RawsState.get_percentage()
        
      when "pumpy_count"
        link = "/munin/localdomain/#{@reporter}-alois_sinkflows.html"

        title = "Count"
        result = 0
        for klass in Prisma::Database.get_classes(:raw) 
          result = result + read_rrd(@reporter, 'alois_sinkflows', "#{klass.table_name}_incoming")
        end

      when "pumpy_out"
        link = "/munin/localdomain/#{@reporter}-alois_sinkflows.html"
        
        result = 0
        for klass in Prisma::Database.get_classes(:raw) 
          result = result + read_rrd(@reporter, "alois_sinkflows", "#{klass.table_name}_outgoing")
        end

      when "reports_today"
	link = url_for(:controller => "reports")
	result = Report.count(:conditions => ["date = ?", "today".to_time])
	title = "Reports today"
	
      when "alarms_today"
	link = url_for(:controller => "alarms", :action => 'status')
	result = Alarm.count(:conditions => ["created_at >= ?", "today".to_time.strftime("%F")])
	title = "Alarms today"
	
      when "yellow_alarms"
	link = url_for(:controller => "alarms", :action => 'status')
	result = Alarm.count(:conditions => Alarm::ACTIVE_YELLOW_CONDITION)
	result = "<span style='background-color:yellow'>#{result}</span>" if result > 0
	title = "Alarms of level: #{Alarm::YELLOW_LEVELS.join(",")}"

      when "red_alarms"
	link = url_for(:controller => "alarms", :action => 'status')
	result = Alarm.count(:conditions => Alarm::ACTIVE_RED_CONDITION)
	result = "<span style='background-color:red'>#{result}</span>" if result > 0
	title = "Alarms of level: #{Alarm::RED_LEVELS.join(",")}"


#      when "prisma_archiv"
#        link = "/munin/localdomain/#{@reporter}-df.html"
#	result = read_rrd(@reporter, "df", "/var/")

        
      else
        throw "unknown type"
      end
      
      result = (result.to_f * 100).round.to_f / 100 if result.class.name == "Float"
    rescue
      result = "EE"
      if RAILS_ENV == "development"
	result += $!.message
      end
    end

    if link
      return "<a class='paint_link' href='#{link}' title='#{title}'>#{result}</a>" 
    else
      return "#{result}"
    end
  end
  
  def measure_inline
    init
    val = measure(params[:type])
    render :text => val, :layout => false
  end

  def status
  end

  def load_default_working_items
    @text = Prisma.load_default_working_items.map {|item|
      if item.class.name == "String"
	item
      else
	if item.respond_to?(:name)
	  "#{item.class.name} '#{item.name}' imported"
	else
	  "#{item} imported"
	end
      end
    }.join("\n") 
    @text = "No items to import." if @text == ""
  end

end
