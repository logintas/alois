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

  class SyslogdSmallBaseMeta < ActiveRecord::Base
    
    description "Small syslogd meta"
    sources ["PureMeta", "LogMeta"]

    def self.expressions
      ret = []
      
      ret.push({ :regex => /(.*?)\|(.*?)\|(.*?)\|(.*?)\|(.*)\|(.*)/,
		 :fields => [:date, :time, :level, :ip, :message,nil]})
    end

    def get_hash
      return nil unless message
      return "#{date} #{time} #{ip} #{message.msg}".hash
    end
    
  end
