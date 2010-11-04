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

class ConditionTest < ActiveSupport::TestCase

  def test_sql_serialize
    c = Condition.create(nil,"SQL","a=b")
    re = Prisma.from_yaml(c.to_yaml)
    assert re
    assert "SQL",c.operator
    assert "( a=b )", c.value
  end

  def test_sql_serialize_arr
    c = Condition.create(nil,"SQL","a=b")
    re = Prisma.from_yaml([c].to_yaml)[0]
    assert re
    assert "SQL",c.operator
    assert "( a=b )", c.value
  end
  
  def test_sql_condition
    c = Condition.create(nil,"SQL","a=b")
    assert_equal "SQL", c.operator
    assert_equal "a=b", c.value
    assert_equal "( a=b )", c.sql
    assert_equal "", c.column
    assert c.valid?(ApplicationLog)
  end

end
