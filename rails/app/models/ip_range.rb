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

class IpRange < ActiveRecord::Base

  validates_presence_of :name, :from_ip
  
  # Validates if all IP-fields can be parse.
  validate do |ir|
    ir["from_ip"].to_ip rescue ir.errors.add("from_ip",$!)
    (ir["to_ip"].to_ip rescue ir.errors.add("to_ip",$!)) unless ir.to_ip.blank?
    (ir["netmask"].to_ip rescue ir.errors.add("netmask",$!)) unless ir.netmask.blank?
  end

  # Find all ip-ranges that the given IP includes.
  def self.find_including_range(ip)
   IpRange.find(:all,:conditions => ["((INET_ATON(from_ip) = INET_ATON(?) AND (to_ip = '' OR to_ip IS NULL)) OR  (INET_ATON(from_ip) <= INET_ATON(?) AND INET_ATON(?) <= INET_ATON(to_ip))) AND enabled = 1", ip.to_s, ip.to_s, ip.to_s],
		 :order => "INET_ATON(from_ip) DESC,INET_ATON(to_ip) DESC")
  end

  # Return true if the iprange contans only one single IP.
  def single_ip?
    return true if to_ip.blank? and netmask.blank?
  end

  # Returns from_ip as IpAddress object (if parsing failed, unparesd field is returned)
  def from_ip
    return super.to_ip if super
  rescue
    super
  end

  # Returns to_ip as IpAddress object (if parsing failed, unparesd field is returned)
  def to_ip
    return super.to_ip if super
  rescue
    super
  end

  # Returns netmask as IpAddress object (if parsing failed, unparesd field is returned)
  def netmask
    return super.to_ip if super
  rescue
    super
  end

end
