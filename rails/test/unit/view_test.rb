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

class ViewTest < ActiveSupport::TestCase
  
  def test_insert_condition
    condition = "abc = 'xyz'"
    tests = {
      "SELECT * FROM xyz WHERE id = 1" => "SELECT * FROM xyz WHERE #{condition} AND id = 1",
      "SELECT * FROM xyz WHERE id = 1 HAVING id = 1" => "SELECT * FROM xyz WHERE #{condition} AND id = 1 HAVING id = 1",
      "SELECT * FROM xyz WHERE id = 1 GROUP BY a" => "SELECT * FROM xyz WHERE #{condition} AND id = 1 GROUP BY a",
      "SELECT * FROM xyz WHERE id = 1 ORDER BY a" => "SELECT * FROM xyz WHERE #{condition} AND id = 1 ORDER BY a",
      "SELECT * FROM xyz WHERE id = 1 LIMIT 1" => "SELECT * FROM xyz WHERE #{condition} AND id = 1 LIMIT 1",
      "SElECT * FRoM xyz WHErE id = 1 GROuP BY a HAViNG id = 1 ORDeR BY z LIMiT 100" => "SElECT * FRoM xyz WHErE #{condition} AND id = 1 GROuP BY a HAViNG id = 1 ORDeR BY z LIMiT 100",
      "SELECT * FROM xyz WHERE id = 1 GROUP BY a HAVING id = 1 ORDER BY z LIMIT 100" => "SELECT * FROM xyz WHERE #{condition} AND id = 1 GROUP BY a HAVING id = 1 ORDER BY z LIMIT 100",
      "SELECT * FROM xyz" => "SELECT * FROM xyz WHERE #{condition}",
      "SELECT * FROM xyz HAVING id = 1" => "SELECT * FROM xyz WHERE #{condition} HAVING id = 1",
      "SELECT * FROM xyz GROUP BY a" => "SELECT * FROM xyz WHERE #{condition} GROUP BY a",
      "SELECT * FROM xyz ORDER BY a" => "SELECT * FROM xyz WHERE #{condition} ORDER BY a",
      "SELECT * FROM xyz LIMIT 1" => "SELECT * FROM xyz WHERE #{condition} LIMIT 1",
      "SELECT * FROM xyz GROUP BY a HAVING id = 1 ORDER BY z LIMIT 100" => "SELECT * FROM xyz WHERE #{condition} GROUP BY a HAVING id = 1 ORDER BY z LIMIT 100"    }
    
    tests.each {|test, expected|
      assert_equal expected, View.insert_condition(test,condition)
    }
    tests.each {|test, expected|
      assert_equal test, View.insert_condition(test,nil)
    }
    tests.each {|test, expected|
      assert_equal test, View.insert_condition(test,"")
    }
  end

  def test_insert_limit_offset
    assert_equal "SELECT * FROM x LIMIT 44, 55", View.insert_limit_offset("SELECT * FROM x", 55, 44)
    assert_equal "SELECT * FROM x LIMIT 55", View.insert_limit_offset("SELECT * FROM x", 55)
    assert_equal "SELECT * FROM x LIMIT 44, 55", View.insert_limit_offset("SELECT * FROM x LIMIT 324,234", 55, 44)
    assert_equal "SELECT * FROM x LIMIT 44, 55 ", View.insert_limit_offset("SELECT * FROM x LIMIT 324, 234 ", 55, 44)
    assert_equal "SELECT * FROM x LIMIT 55", View.insert_limit_offset("SELECT * FROM x LIMIT 3", 55)
    assert_equal "SELECT * FROM x LIMIT 55", View.insert_limit_offset("SELECT * FROM x LIMIT 3  OFFSET  3223", 55)
  end

  def test_insert_order
    order = "sum(xx), test"
    assert_equal "SELECT * FROM x ORDER BY #{order}", View.insert_order("SELECT * FROM x",order)
    assert_equal "SELECT * FROM x WHERE a = b ORDER BY #{order}", View.insert_order("SELECT * FROM x WHERE a = b",order)
    assert_equal "SELECT * FROM x ORDER BY #{order} LIMIT 324,234", View.insert_order("SELECT * FROM x LIMIT 324,234",order)
    assert_equal "SELECT * FROM x ORDER BY #{order} LIMIT 324, 234 ", View.insert_order("SELECT * FROM x ORDER BY sum(xxx) , ss ASC LIMIT 324, 234 ", order)
    assert_equal "SELECT * FROM x ORDER BY #{order}", View.insert_order("SELECT * FROM x ORDER BY sum(xxx) , ss ASC", order)
  end
  
  def test_update_query
    condition = "abc = 'xyz'"
    order = "abc, count(dd)"
    limit = 3
    offset = 4
    tests = { "SELECT * FROM xyz WHERE id = 1 GROUP BY a HAVING id = 1 ORDER BY z LIMIT 100" =>
      "SELECT * FROM xyz WHERE #{condition} AND id = 1 GROUP BY a HAVING id = 1 ORDER BY #{order} LIMIT #{offset}, #{limit} "}

    tests.each {|test, result|
      u_test = test + " UNION " + test + " UNION ALL " + test + " UNION DISTINCT " + test + " UniON DISTINCT " + test
      u_result = "(" + result + ") UNION (" + result + ") UNION ALL (" + result + ") UNION DISTINCT (" + result + ") UNION DISTINCT (" + result + ")"
      assert_equal u_result, View.update_query(u_test,:conditions => condition, :order => order, :limit => limit, :offset => 4)

      u_test = "(" + test + ") UNION (" + test + ") UNION ALL (" + test + ") UNION DISTINCT (" + test + ") UniON DISTINCT (" + test + ")"
      u_result = "(" + result + ") UNION (" + result + ") UNION ALL (" + result + ") UNION DISTINCT (" + result + ") UNION DISTINCT (" + result + ")"
      assert_equal u_result, View.update_query(u_test,:conditions => condition, :order => order, :limit => limit, :offset => 4)
    }

  end
  
end
