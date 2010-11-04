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

module PrismaHelper

  def start_painting_div(x,y)
    
  end
  
  def query_background_color(hash)
    case hash["Command"]
    when "Query"
      "FF" + (if (t = hash["Time"].to_i) > 255 then 
	"00" 
      else 
	(255 - t).to_s(16)
      end) * 2
    when "Statistics"
      "transparent"
    when "Sleep"
      "AAFFAA"
    else
      "transparent"
    end
  end

  def host_name_div(name, x, y, help_context = nil)
    help = help_button help_context if help_context
    if name =~ /([^\.]*).*/ then
      short_name = $1 
    else
      short_name = name
    end
    "<div class='paint_host' style='left:#{x}px;top:#{y}px;'>" +
      "<a href='/munin/localdomain/#{name}.html'>#{short_name}</a> #{help}" +
      "</div>"
  end

  def arrow_div(name, x, y)
    "<div class='paint_arrow' style='left:#{x}px;top:#{y}px;'>" +
      "<span id='#{name}'>#{@controller.measure(name)}</span> #{help_button name}" +
      "</div>"
  end

  def updating_value(name)
    "<span id='#{name}'>#{@controller.measure(name)}</span>"
  end
  
end
