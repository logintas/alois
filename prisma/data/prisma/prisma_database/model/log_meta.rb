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

  class LogMeta < ActiveRecord::Base
    description "Simple log metas with date, time and host."
    sources ["SyslogdMeta", "PureMeta", "FileMeta"]

    def self.reproducable 
      false
    end
        

    def self.expressions
      ret = []
      ret.push({ :condition => lambda {|mesage, meta_class, meta_instance| meta_class == PureMeta },
		 :regex => /^([^ ]*) *(\d+) (..:\d\d:\d\d) ([^ ]*) (.*)$/,
		 :result_filter => lambda {|results, meta_instance| 		   
		   results[0] = DateTime.strptime("#{results[0]} #{results[1]} #{Time.now.year}", "%b %d %Y")
		   results.delete_at(1)
		   results
		 },
		 :fields => [:date, :time, :host, :message]})      
      return ret
    end
        
    def get_hash
      return nil unless message
      return "#{date} #{time} #{host} #{message.msg}".hash
    end
  end
