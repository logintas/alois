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

class SwissmentorBaseMeta < ActiveRecord::Base

  description "Swissmentor Logs"
  sources ["PureMeta", "LogMeta"]
  
  
  def self.expressions
    ret = []

    # SMS: [broesel@127.0.0.1] Login successful for user broesel
    ret.push({ :regex => /^(\S+): \[(\S*)\@(\S+)\] (Login denied for user|Login request user|Login successful for user):? (.*)$/,
               :fields => [:process, :client_user, :client_ip, :message],
               :result_filter => lambda {|results, instance|                 
                 results[1] = results[4] if results[1].blank?
                 if results[1] != results[4]
                   result[3] += ": #{results[4]}"
                 end
                 results.pop
                 results
               }})

    ret.push({ :regex => /^(\S+): \[(\S*)\@(\S+)\] (.*)$/,
               :fields => [:process, :client_user, :client_ip, :message]})
    return ret
  end
  
end

