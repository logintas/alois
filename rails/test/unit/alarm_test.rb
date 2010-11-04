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

class AlarmTest < ActiveSupport::TestCase
  fixtures :alarms

  # Replace this with your real tests.
  def test_status_color
#    assert_equal "green",Alarm.status_color
    Alarm.delete_all
    assert_equal "green",Alarm.status_color
    Alarm.create(:alarm_level => 7)
    assert_equal 1,Alarm.count
    assert_equal "green",Alarm.status_color
    Alarm.create(:alarm_level => 6)
    assert_equal "green",Alarm.status_color
    Alarm.create(:alarm_level => 5)
    assert_equal "green",Alarm.status_color
    Alarm.create(:alarm_level => 4)
    assert_equal "yellow",Alarm.status_color
    Alarm.create(:alarm_level => 3)
    assert_equal "orange",Alarm.status_color
    Alarm.create(:alarm_level => 2)
    assert_equal "red",Alarm.status_color
    Alarm.create(:alarm_level => 1)
    assert_equal "red",Alarm.status_color
    Alarm.create(:alarm_level => 0)
    assert_equal "red",Alarm.status_color
  end
end
