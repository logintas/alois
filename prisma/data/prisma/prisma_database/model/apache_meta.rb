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

  class ApacheMeta < ActiveRecord::Base

    description "Parsed apache messages"
    sources ["PureMeta", "LogMeta"]

    def self.may_have_messages?; false; end

    def self.expressions
      ret = []
      ret.push({ :condition => lambda {|message, meta_class, meta_instance| meta_class == PureMeta },
		 :regex => /^(?:.*(?:apache|apache2):\s+)?(\S+)\s+(.*?)\s+(.*?)\s+\[(\d+\/\S+\/\d+:\d+:\d+:\d+\s+.*?)\]\s+\"(.*?)\"\s+(\S+)\s+(\S+)\s+\"(.*?)\"\s+\"(.*?)\"\s+\"(.*?)\"\s+(\S+)\s+(\S*)\s*(.*)$/,
		 :result_filter => lambda {|results, meta_instance| 
		   datetime = DateTime.strptime(results[3], "%d/%b/%Y:%H:%M:%S %Z")
		   results[12] = results[12].strip if results[12]
                   results[12] = nil if results[12] == ''

		   meta = ApacheLogMeta.new.prisma_initialize(meta_instance,{ 
					    :forensic_id => results.delete_at(9),
					    :serve_time => results.delete_at(9),
					      :host => results.delete_at(9)})
		   results[3] = Time.local(datetime.year(), datetime.month(), datetime.day(), datetime.hour(), datetime.min(), datetime.sec())
		   results.push(datetime)
		   results
		 },
		 :fields => [:remote_host, :remote_logname, :remote_user, :time, :first_line, :status, :bytes, :referer, :useragent, :message, :date]})
      
      # apache: test.example.com - - [11/Jul/2006:02:12:24 +0200] "GET / HTTP/1.0" 302 332 "-" "check_http/1.81 (nagios-plugins 1.4)" "-" 0 www2.example.com
      # apache: test.example.com - - [07/Jul/2006:13:27:28 +0200] "GET / HTTP/1.1" 302 345 "-" "Mozilla/5.0 (X11; U; Linux i686; de; rv:1.8.0.4) Gecko/20060608 Ubuntu/dapper-security Firefox/1.5.0.4" "-" 0 www2.example.com
      # LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%{forensic-id}n\" %T %v" full

      ret.push({ :condition => lambda {|message, meta_class, meta_instance| meta_class == LogMeta },
		 :regex => /^.*(?:apache|apache2):\s+(\S+)\s+(.*?)\s+(.*?)\s+\[(\d+\/\S+\/\d+:\d+:\d+:\d+\s+.*?)\]\s+\"(.*?)\"\s+(\S+)\s+(\S+)\s+\"(.*?)\"\s+\"(.*?)\"\s+\"(.*?)\"\s+(\S+)\s+(\S*)\s*(.*)$/,
		 :result_filter => lambda {|results, meta_instance| 
		   datetime = DateTime.strptime(results[3],"%d/%b/%Y:%H:%M:%S %Z")		   
		   results[12] = results[12].strip if results[12]
                   results[12] = nil if results[12] == ''

		   meta = ApacheLogMeta.new.prisma_initialize(meta_instance,{ 
					    :forensic_id => results.delete_at(9),
					    :serve_time => results.delete_at(9),
					      :host => results.delete_at(9)})
		   results[3] = Time.local(datetime.year(), datetime.month(), datetime.day(), datetime.hour(), datetime.min(), datetime.sec())
		   results.push(datetime)
		   results
		 },
		 :fields => [:remote_host, :remote_logname, :remote_user, :time, :first_line, :status, :bytes, :referer, :useragent, :message, :date]})
      return ret
    end
    
  end

