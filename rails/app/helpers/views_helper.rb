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

module ViewsHelper
  UNGROUPED_NAME = ""
  
  def make_groups(views)
    groups = {}
    
    views.each {|v|
      names = (v.name or "").split(" ") 

      groups[names[0]] = [] unless groups[names[0]]
      groups[names[0]].push(v)

    }

    groups.each {|key,views|
      if views.length == 1
	groups[UNGROUPED_NAME] = [] unless groups[UNGROUPED_NAME]
	groups[UNGROUPED_NAME].push(views[0])
	groups.delete(key)
      end
      views.sort! {|a,b| (a.name or "") <=> (b.name or "") }
    }
        
    groups[UNGROUPED_NAME].sort! {|a,b| (a.name or "") <=> (b.name or "") } if groups[UNGROUPED_NAME]
    groups
  end

end
