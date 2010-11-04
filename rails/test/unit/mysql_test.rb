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

require File.dirname(__FILE__) + '/../test_helper'

class MysqlTest < ActiveSupport::TestCase

  def test_kill_queries
    # not yet working
    return
    long_query = "SELECT * FROM alarms"
    5.times {|i| 
          long_query += " CROSS JOIN alarms AS a#{i}"
    }
    # prevent caching
    long_query = " WHERE alarms.id != NOW()"
    timeout_reached = false
    begin
      Timeout::timeout(1) {
	ActiveRecord::Base.connection.execute(long_query)
      }
    rescue Timeout::Error
      timeout_reached = true
    end
    assert timeout_reached, "Timeout not reached"
  end

end
