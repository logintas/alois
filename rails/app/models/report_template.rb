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

class ReportTemplate < ActiveRecord::Base

  has_and_belongs_to_many :tables, :order => "priority"
  has_and_belongs_to_many :charts, :order => "priority"

  belongs_to :view
  has_many :reports
  has_many :sentinels

  attr_accessor :mode
  attr_accessor :parent_obj

  # only for validation needed
  attr_accessor :ds

  validate do |rt|
    ds = rt.ds
    rt.charts.each {|c|     
      rt.errors.add_to_base("Chart '#{c.name}' not applyable to datasource #{ds.to_s}.") unless c.applyable?(ds)
    }
    rt.tables.each {|t| 
      rt.errors.add_to_base("Table '#{t.name}' not applyable to datasource #{ds.to_s}.") unless t.applyable?(ds)
    }
  end

  def applyable?(datasource)
    self.ds = datasource
    return self.valid?
  end


  def datasource(options = {})
    return options[:datasource] if options and options[:datasource]
    return parent_obj.datasource if parent_obj.respond_to?(:datasource) and parent_obj.datasource
    return view if view      
    raise "No view and no parent_obj data available for real rendering (parent_obj: #{parent_obj.inspect})." unless mode == :preview
  end
  
  def datasource_depr(options = {})
    my_view = find_view(options)
    case mode
    when :preview
    when :real
      return my_view
    end
    nil
  end

  def set_data_directory(dir)
    @data_directory = dir
  end
  def cache_exist?
    data_directory(false).exist?
  end
  def delete_cache  
    raise "Unexpected cache directory: '#{data_directory}'" if     
      !(data_directory.realpath.to_s =~ Regexp.new("^#{Regexp.escape((Pathname.new(RAILS_ROOT) + "tmp/reports/").realpath.to_s)}"))
    d = data_directory
    d.rmtree if d.exist? and d.directory?
  end  
  def data_directory(create = true)
    return Pathname.new(@data_directory) if @data_directory
    p = Pathname.new(RAILS_ROOT) + "tmp/reports/#{id}"
    p.mkpath if create
    p
  end

  def render(options = {})
    self.parent_obj = options[:parent]
    
    my_charts(options).each{|ch| ch.render(options) }
    my_tables(options).each{|tb| tb.render(options) }    

    @count  = data_count(options)

    moptions = options.clone
    moptions[:relative_path] = data_directory

    open((data_directory + "index.html").to_s,"w") {|f|
      f.write(text(moptions))
    }    
  end

  def charts_with_sources; my_charts; end
  def my_charts(options = {})
    case mode
    when :archive
      Dir.glob(data_directory + "chart.*/").sort {|d1,d2|
	# sort with according to the number
	(d1 =~ /chart\.(\d*)\/$/;$1.to_i) <=> (d2 =~ /chart\.(\d\/*)$/; $1.to_i)
      }.map {|dir|
	Chart.load_yaml(dir,nil)
      }
    when :preview
      num = 0
      charts.map {|chart|
	dir = (data_directory + "chart.#{num}/").to_s
	num += 1
	if File.exist?(dir)
	  Chart.load_yaml(dir,nil)
	else
	  chart.datasource = datasource(options)
	  chart.set_data_directory(dir)	
	  chart
	end
      }
    else
      num = 0
      charts.map {|chart|
	chart.datasource = datasource(options)
	chart.set_data_directory((data_directory + "chart.#{num}").to_s)	
	num += 1
	chart
      }
    end
  end

  def tables_with_sources; my_tables; end
  def my_tables(options = {})
    case mode
    when :archive
      Dir.glob(data_directory + "table.*/").sort {|d1,d2|
	# sort with according to the number
	(d1 =~ /table\.(\d*)\/$/;$1.to_i) <=> (d2 =~ /table\.(\d\/*)$/; $1.to_i)
      }.map {|dir|
	Table.load_yaml(dir)
      }
    else
      num = 0
      tables.map {|table|
	table.datasource = datasource(options)
	table.set_data_directory((data_directory + "table.#{num}").to_s)
	num += 1
	table
      }      
    end
  end

  def files
    my_charts.map {|ch| ch.png_file_name}
  end

  def data_count(options = {})
    return @count if defined?(@count)
    throw "Count not defined for mode archive." if mode == :archive
    return "NOT AVAILABLE" if mode == :preview

    ds = self.datasource(options)
    if ds.respond_to?(:data)
      ds.data.length
    else
      ds.table.count(:conditions => options[:conditions])
    end
  end

  def text(options = {})
    options ||={}
    return super unless mode
    t = super.clone
    num = -1
    mcharts = my_charts(options)
    t.gsub!("<<CHART>>") {|match|
      num += 1
      options[:chart_number] = num
      begin
	chart = mcharts[num]
	raise "Too few charts defined." unless chart
	if options[:absolute_path]
	  options[:link] ||= @external_link
	end
	chart.image_map(options) + chart.image_tag(options)
      rescue
	"<span style='color:red;'>Cannot insert chart: #{$!}</span>"
      end
    }

    num = -1
    mtables = my_tables(options)
    t.gsub!("<<TABLE>>") {|m|
      num += 1
      begin
	table = mtables[num]
	raise "Too few tables defined." unless table
	table.html
      rescue
	"<span style='color:red;'>Cannot insert table: #{$!}</span>"
      end
    }

    t.gsub!("<<COUNT>>") { data_count(options)}
    t.gsub!("<<VIEW>>") { self.datasource(options) and self.datasource(options).name }
    t.gsub!("<<CONDITIONS>>") { options[:conditions]}
    t.gsub!("<<CONDITION>>") { options[:conditions] }
      
    t
  end

#  def save
#    self.version ||= 0
#    self.version += 1
#    super
#  end

end
