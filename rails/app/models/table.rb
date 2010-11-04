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

class Table < ActiveRecord::Base
  has_and_belongs_to_many :report_templates
  
  attr_accessor :datasource
  attr_accessor :conditions
  
  validate do |t|
    if t.datasource
      cns = t.datasource.table.columns.map{|c| c.name}
      ["columns","order_by","group_by"].each {|name|
	missing_cols = t.send("#{name}_arr").reject {|cn| cns.include?(cn) }
	t.errors.add(name,"Missing columns in datasource: #{missing_cols.inspect}.") unless
	  missing_cols.length == 0
      }
    end
  end
  
  def columns_arr
    @columns_arr = columns.split(",").map{|n|
      if n =~ /\((.*)\)/
	$1.strip
      else
	n.strip
      end
    }.reject {|n| n == "*"}
    @columns_arr
  end
  def order_by_arr
    return [] if order_by.nil? or order_by.strip == ""
    group_by.split(",").map{|n| n.strip.split(" ")[0]}
  end
  def group_by_arr
    return [] if group_by.nil? or group_by.strip == ""
    group_by.split(",").map{|n| n.strip}
  end
  def needed_column_names
    columns_arr + order_by_arr + group_by_arr
  end
    
  def applyable?(ds)
    t = self.clone
    t.datasource = ds
    return t.valid?
  end
  
  def text
    render
    return open(text_filename) {|f| f.readlines} if File.exist?(text_filename)
  end
  
  def html
    "<pre>#{text}</pre>"
  end
  
  def base_name; (data_directory + "table").to_s; end
  
  def data_filename; base_name + ".data"; end
  def data_date; File.mtime(data_filename) rescue nil; end
  
  def text_filename; base_name + ".txt"; end
  def text_date; File.mtime(text_filename) rescue nil; end
  
  def save_yaml
    open((base_name + ".yaml"),"w") {|f| f.write(self.clone.to_yaml)}
  end
  
  def self.load_yaml(data_dir)
    if data_dir.to_i == 0
      data_directory = Pathname.new(data_dir)
      raise "Data '#{data_dir}' directory not found." unless data_directory.exist?
    else
      data_directory = Pathname.new(RAILS_ROOT) + "tmp/tables/#{data_dir}"
    end
    file = (data_directory + "table.yaml").to_s
    t = Table.from_yaml(open(file,"r"){|f|f.readlines.join})
    t.set_data_directory(data_directory)
    t
  end
  
  def render(options = {})
    return if File.exist?(text_filename) and not (text_date < data_date rescue false)
    save_yaml
    
    data = get_data
    if data.column_names.length == 0
      txt =  "--------------------------\n"
      txt += "| No columns to display. |\n"
      txt += "--------------------------\n"
    else
      txt = data.as(:text, :ignore_table_width => true)      
    end
    open(text_filename,"w") {|f| f.write(txt) }
  end
  
  def set_data_directory(dir)
    @data_directory = dir
  end
  def data_directory
    if @data_directory
      p = Pathname.new(@data_directory)
    else
      p = Pathname.new(RAILS_ROOT) + "tmp/tables/#{id}"
    end
    p.mkpath
    p
  end
  def delete_data
    d = data_directory
    d.rmtree if d.exist? and d.directory?
  end

  def group_by
    return nil if super and super == ""
    super
  end

  def order_by
    return nil if super and super == ""
    super
  end

  def to_csv
    get_data.to_csv
  end
  def as(type, options = {})
    d = get_data
    return nil if d.length == 0
    d.as(type,options)
  end
  def count
    get_data.length
  end

  def remove_cache
    File.delete(data_filename) if File.exists?(data_filename)
  end

  def get_data(recreate_data = false)     
    if !recreate_data and File.exists?(data_filename)
      @data = YAML::load(File.open(data_filename))
    else
      
      if datasource.respond_to?(:data)
	raise "Group by not supported by this datasource '#{datasource.name}'" if group_by
	raise "Order by not supported by this datasource '#{datasource.name}'" if order_by

	data = datasource.data
	cols = datasource.columns.map{|c| c.name}.select {|n| columns_arr.include?(n)}
	data = data.map {|row|
	  nr = []
	  cols.each{|col| nr.push(row[col])}
	  nr
	}
	
	@data = Ruport::Data::Table.new :data => data, :column_names => cols
	
      else
	@data = @datasource.table.report_table(:all, 
					       :select => if (columns.nil? or columns == "") then nil else columns end,
					       :limit => max_count, 
					       :only => if (columns.nil? or columns == "") then nil else columns.split(",").map{|n| n.strip} end, 
					       :order => order_by,
					       :group => group_by,
					       :conditions => conditions)
      end
      
      File.open(data_filename, 'w') { |f| f.puts @data.to_yaml }
    end
    @data
  end
  
end
