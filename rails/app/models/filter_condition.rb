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

# Condition based on filters.
# Possible values are a comma separated list of filter_ids.
class FilterCondition < Condition

  def applyable(options = {})
    filters.each {|f| 
      return false unless f.applyable(options)
    }
    true
  end

  def filters
    f = []
    value.gsub(/\d+/) {|m| f.push(Filter.find(m))}
    f
  end
   
  def sql(options = {})    
    value.gsub(/\d+/) {|m| Filter.find(m).sql(options)}
  end
  
end
