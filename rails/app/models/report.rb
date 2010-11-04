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

class Report < ActiveRecord::Base
  
  belongs_to :report_template
  belongs_to :alarm
  belongs_to :sentinel


  def self.archive_path(path, conditions)
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

  def parent
    alarm or sentinel
  end

  def self.default_report_template
    ReportTemplate.new(:title => "Default Sentinel Report", :text => 
		       "#{self.description}<br><br><<DEFAULTTABLE>>")
  end

  def self.generate(report_template, generated_by, options = {})
    rep = Report.new
    raise "No report_template given." unless report_template
    raise "No generator given." unless generated_by

    case generated_by.class.to_s
    when "Sentinel"
      rep.sentinel = generated_by
      rep.generated_by = "sentinel"
    when "Alarm"
      rep.alarm = generated_by
      rep.generated_by = "alarm"
    when "String"
      rep.generated_by = generated_by
    else
      raise "Don't know how to create report (create by: '#{generated_by}' #{generated_by.class})."
    end

    rep.report_template = report_template

    now = DateTime.now
    rep.date = now.strftime("%F")
    rep.time = now.strftime("%T")
    rep.name = "#{report_template.name or "NONAME"}" + (" for #{options[:datasource].name}" rescue "")
    p = Pathname.new(archive_path($report_archive_pattern, {
				    :date => rep.date,
				    :time => rep.time,
				    :name => (rep.name or "NONE")}))
    p.mkpath
    rep.path = p.to_s
    rep.create_files(options)
    rep.save
    return rep
  end

  def pathname
    p = Pathname.new(path)
  end
  
  def write_file(name, text)
    open("#{pathname + name}","w") {|f| f.write(text) }
  end

  def load_file(name)
    open("#{pathname + name}","r") {|f| f.readlines.join }
  end

  def create_files(options = {})
    raise "Report already saved. Cannot create files." unless self.new_record?

    rt = report_template
    if rt
      rt.set_data_directory(pathname)
      rt.mode = :real

      options[:parent] = parent
      rt.render(options)
      write_file("report_template.yaml", rt.to_yaml)
    else
      throw "NO REPORT TEMPL"
    end
    
    write_file("sentinel.yaml", sentinel.to_yaml) if sentinel
    
    self.save
  end

  def objects
    original_report_template.charts_with_sources +
    original_report_template.tables_with_sources
  end

  def original_report_template
    rt = ReportTemplate.from_yaml(load_file("report_template.yaml"))
    rt.set_data_directory(path)
    rt.mode = :archive
    rt
  end
  def original_report_sentinel
    ReportTemplate.from_yaml(load_file("sentinel.yaml"))
  end

  def text(options = {})
    original_report_template.text(options)
  end


  def html_deprecated(options = {})
    rt = original_report_template
#    "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">" +
#      "<html>" +
#      "<head>" +
#      "<title>Report #{name} #{date} #{time}</title>" +
#      "</head>" +
#      "<body>" +
      "<h1>#{name}</h1>" +
      (options[:html_pre_text] or "") +
      "<h2>Report</h2>" +      
      (if options[:include_link] then "#{$root_url}reports/show/#{self.id}" end) +
      rt.text({:absolute_path => true}) +
      (options[:html_post_text] or "") 
#      "</body>" +
#      "</html>"
  end

  def html
    rt = original_report_template
    rt.text({:absolute_path => true})
  end

  def files(options = {})
    original_report_template.files
  end    

end
