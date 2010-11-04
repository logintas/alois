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

class IpRangeTest < ActiveSupport::TestCase
  fixtures :ip_ranges

  # Replace this with your real tests.
  def test_ip_range_condition
    # possible values:
    # an ip: 192.168.1.1
    # a range: 192.168.1.1-192.168.1.50
    # an id of a range: 3
    # the name of a filter: Filter 1
    

    assert_equal "INET_ATON(`ip`) = INET_ATON('192.168.1.1') ",
      Condition.create("ip", "IPRANGE", "192.168.1.1").sql
    assert_equal "INET_ATON(`ip`) = INET_ATON('192.168.001.001') ",
      Condition.create("ip", "IPRANGE", "192.168.001.001 ").sql

    assert_equal "INET_ATON(`ip`) >= INET_ATON('192.168.1.1') AND INET_ATON(`ip`) <= INET_ATON('192.168.1.50') ",
      Condition.create("ip", "IPRANGE", "192.168.1.1-192.168.1.50").sql
    assert_equal "INET_ATON(`ip`) >= INET_ATON('192.168.1.1') AND INET_ATON(`ip`) <= INET_ATON('192.168.01.50') ",
      Condition.create("ip", "IPRANGE", " 192.168.1.1 - 192.168.01.50 ").sql

    # by id
    assert_equal "INET_ATON(`ip`) = INET_ATON('192.168.1.1') ",
      Condition.create("ip", "IPRANGE", "1").sql
    assert_equal "INET_ATON(`ip`) >= INET_ATON('192.168.1.1') AND INET_ATON(`ip`) <= INET_ATON('192.168.1.22') ",
      Condition.create("ip", "IPRANGE", "3").sql

    # by name
    assert_equal "INET_ATON(`ip`) = INET_ATON('192.168.1.1') ",
      Condition.create("ip", "IPRANGE", "aa").sql
    assert_equal "INET_ATON(`ip`) >= INET_ATON('192.168.1.1') AND INET_ATON(`ip`) <= INET_ATON('192.168.1.22') ",
      Condition.create("ip", "IPRANGE", "ccc").sql
    
  end
end
