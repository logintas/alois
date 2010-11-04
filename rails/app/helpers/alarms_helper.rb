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

module AlarmsHelper

  def status_traffic_light(options = {})
    color = Alarm.status_color
    img = case color
	  when "red"
	    "traffic_light_red_dan_ge_01.png"
	  when "orange","yellow"
	    "traffic_light_yellow_dan_01.png"
	  when "green"
	    "traffic_light_green_dan__01.png"
	  else
	    "traffic_light_dan_gerhar_01.png"
	  end
    
    return "<a href='#{url_for(:controller => "alarms", :action => 'status')}' title='Current alarm level is: #{color}'>#{image_tag img, options}</a>" 

  end
end
