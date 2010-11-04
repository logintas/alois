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

class SentinelsTest < ActiveSupport::TestCase
  fixtures :sentinels, :application_logs, :filters

  # Replace this with your real tests.
  def test_count
    s = Sentinel.find(2)
    # default is yesterday
    assert_equal 0, s.count
    s.time_range = "2010-09-01"
    assert_equal 0, s.count
    s.time_range = nil
    assert_equal 9, s.count
    s.time_range = "2010-10-01"
    assert_equal 2, s.count

    s.filters = "2"
    assert_equal 0, s.count

    # filter with datum 2007-05-01
    s.filters = "3"
    assert_equal 0, s.count

    s.filters = "2,3"
    assert_equal 0, s.count

    s.filters = ""
    assert_equal 2, s.count

    s.filters = nil
    assert_equal 2, s.count
    
  end

end
