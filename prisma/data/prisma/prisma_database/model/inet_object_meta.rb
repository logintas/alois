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

class InetObjectMeta < ActiveRecord::Base

    description "Object information of inet messages."
    sources ["InetHeaderMeta"]

    def self.expressions
      ret = []

      # old version without object_location
      ret.push({ :regex => /^([^\;]*)\;([^\;]*)\;([^\;]*)\;([^\;]*)\;(\"[^\"]*\"|[^\;]*)\;([^\;]*)\;([^\;]*)\;(.*\;.*\;.*\;.*\;.*\;.*\;.*)$/,
		 :fields => [:objecttype,:object_id,:version,:filename,:description,:object_hashes,:object_url, :message]})
      
      ret.push({ :regex => /^([^\;]*)\;([^\;]*)\;([^\;]*)\;([^\;]*)\;(\"[^\"]*\"|[^\;]*)\;([^\;]*)\;([^\;]*)$/,
		 :fields => [:objecttype,:object_id,:version,:filename,:description,:object_hashes,:object_url]})
      
      # new version with object_location
      ret.push({ :regex => /^([^\;]*)\;([^\;]*)\;([^\;]*)\;([^\;]*)\;([^\;]*)\;(\"[^\"]*\"|[^\;]*)\;([^\;]*)\;([^\;]*)\;(.*\;.*\;.*\;.*\;.*\;.*\;.*\;.*)$/,
		 :fields => [:objecttype,:object_id,:object_location,:version,:filename,:description,:object_hashes,:object_url, :message]})
      

      ret.push({ :regex => /^([^\;]*)\;([^\;]*)\;([^\;]*)\;([^\;]*)\;([^\;]*)\;(\"[^\"]*\"|[^\;]*)\;([^\;]*)\;([^\;]*)$/,
		 :fields => [:objecttype,:object_id,:object_location,:version,:filename,:description,:object_hashes,:object_url]})
      
      return ret
    end

end
