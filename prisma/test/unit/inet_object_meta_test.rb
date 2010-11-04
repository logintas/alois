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

class InetObjectMetaTest < ActiveSupport::TestCase
  fixtures :inet_object_metas

  # Replace this with your real tests.
  def test_convert
    assert_equal "abcdüefg",WindowsEventMeta.convert_to_unicode("abcd37777777774efg")
    ["abcd37777777774efg",
      "abcd37777777744efg"].each {|s|
      assert_equal s, WindowsEventMeta.convert_to_wincode(WindowsEventMeta.convert_to_unicode(s.dup))
    }
  end
end
