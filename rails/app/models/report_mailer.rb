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

class ReportMailer < BaseMailer

  def simple(recipients, report, options = {})    
    text(recipients, report, options)
    part = html(recipients, report, options)

    add_csv(part,report,options) 
  end
  
  def normal(recipients, report, options = {})

    part = text(recipients, report, options)
    part = html(recipients, report, options.update(:attachments => report.files.uniq))
    
    add_csv(part,report,options)
  end

  def compress(hash)
    f = Tempfile.new("/tmp")    
    require "zip/zip"
    Zip::ZipOutputStream::open(f.path) {
      |io|
      hash.each {|key,content|      
	io.put_next_entry(key)
	io.write content
      }
    }
    ret = open(f.path).readlines.join
    f.delete    
    ret
  end
  
  def add_csv(part,report,options)
    options[:add_csv] = true if options[:add_csv].nil?
    return unless options[:add_csv]
    objs = report.objects
    data_hash = objs.map {|obj| ["#{obj.class.name}_#{obj.name}.csv", obj.to_csv]}              
    part.attachment "application/zip" do |a|
      a.body = compress(data_hash)
      a.filename = "csv_datas.zip"
    end
  end

  
end
