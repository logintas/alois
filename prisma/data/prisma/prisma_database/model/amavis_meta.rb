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

  class AmavisMeta < ActiveRecord::Base

    description "Amavis Logs"
    sources ["PureMeta", "LogMeta"]
    
    preseed_expression /^amavis\[/

    def self.may_have_messages?; false; end
    
    def self.expressions
      ret = []
      
      ret.push({ :regex => /^amavis\[([^\]]*)\]: \(([^)]*)\) ([^ ]*) ([^,]*), \[([^\]]*)\] ([^ ]*) -> (.*), Message-ID: ([^,]*), Hits: ([^,]*), ([^ ]*) ms( *)$/,
		 :fields => [:process_id, :amavis_id, :action, :status, :ip, :from_field, :to_field,
		   :message_id, :hits, :process_time,nil]})
      
      ret.push({ :regex => /^amavis\[([^\]]*)\]: \(([^)]*)\) ([^ ]*) ([^ ]*) \(([^)]*)\), ([^ ]*) -> (.*), quarantine: ([^,]*), Hits: ([^,]*), ([^ ]*) ms( *)$/,
		 :fields => [:process_id, :amavis_id, :action, :status, :signature,
		   :from_field, :to_field, :quarantine, :hits, :process_time,nil]})
      
      return ret
    end
    
  end


