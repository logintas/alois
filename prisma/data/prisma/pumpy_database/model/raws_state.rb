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

  class RawsState < ActiveRecord::Base

    description "Syslogd raw status table on pumpy."

    def self.get_percentage
      percents = []
      count = 0
      for klass in Prisma.get_classes(:raw)
	recs = find(:all,:order => "id DESC", :limit => 1, :conditions => "table_name = '#{klass.table_name}'")
	if recs.length == 1 
	  percents.push(recs[0].percentage)
	  count = count + 1
	end
      end
      percents.max
    end
        
    def percentage
      begin
	(100. / count_limit.to_f) * count_value.to_f
      rescue
	100
      end
    end

  end

