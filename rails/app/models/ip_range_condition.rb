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

# Condition for selecting IPs.
# possible values:
# an ip: 192.168.1.1
# a range: 192.168.1.1-192.168.1.50
# an id of a range: 3
# the name of a filter: Filter 1
class IpRangeCondition < Condition
  
  # Find iprange represented by value. Either by id or name.
  def find_ip_range
    begin
      IpRange.find(@value)
    rescue
      IpRange.find_by_name(@value)
    end
  rescue
    nil
  end

  # This condition cannot be updated from UI
  def updatable?; false; end

  # Returns the range represented by value.
  def range
    case @value
    when /^\s*(\d+\.\d+\.\d+\.\d+)\s*$/
      $1.to_ip
    when /^\s*(\d+\.\d+\.\d+\.\d+)\s*(\.\.|\-)\s*(\d+\.\d+\.\d+\.\d+)\s*$/
      ($1.to_ip..$3.to_ip)
    else
      ipr = find_ip_range
      raise "Cannot find iprange '#{@value}'." unless ipr
      if ipr.to_ip
	(ipr.from_ip..ipr.to_ip)
      else
	ipr.from_ip
      end
    end
  end

  # Human readable text of the value (probably not really what you expect)
  def value
    if ipr = find_ip_range
      ipr.name + ": " + range.to_s
    else
      range.inspect
    end
  end

  # Return true if the condition includes only a single IP
  def exact_ip?
    range.class.name == "IpAddress"
  end
  
  # SQL condition. MySQL function INET_ATON is used to convert ip name to comparable values but
  # the column itself must contain "human readable" ipaddresses.
  # Maybe later implementation will respect column type to compare against integer represented ipaddresses in database.
  def sql(options = {})
    ret = ""
    if exact_ip?
      ret += "INET_ATON(#{column}) = INET_ATON('#{self.range}') "
    else
      ret += "INET_ATON(#{column}) >= INET_ATON('#{self.range.first}') AND "
      ret += "INET_ATON(#{column}) <= INET_ATON('#{self.range.last}') "
    end
    return ret
  end
  
end
