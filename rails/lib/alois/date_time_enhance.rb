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

class Time

  def beginning_of_minute
    change(:sec => 0)
  end

  def beginning_of_hour
    change(:min => 0).beginning_of_minute
  end


  def end_of_minute
    change(:sec => 59)
  end

  def end_of_hour
    change(:min => 59).end_of_minute
  end
  
  # day and month already included
  
  def end_of_week
    6.days.from_now(beginning_of_week).end_of_day
  end
  
  def end_of_year
    change(:month => 12).end_of_month
  end

  def self.suggest(text, with_range = true)
    text = text.strip

    case text
    when nil, ""
      ret = ["beginning","end","last","this","today","yesterday","NUMBER"]
      ret.push("from") if with_range 
      ret
    when /^(beginning *)$/, /^(end *)$/
      ret = ["last","this","today","yesterday","NUMBER"]
      ret.push("from") if with_range 
      ret.map{|v| "#{$1} #{v}"}
    when /^(from .* until)(.*)/
      self.suggest($2,false).map{|v| "#{$1} #{v}"}
    when /^(from)(.*)/
      ret = self.suggest($2,false).map {|v| "#{$1} #{v}"}
      if (($2 or "").strip.to_time rescue false)
	ret.push("#{text} until")
      end
      ret
    when /^(from .* )(-|to|until|till|up to) (.*)/
      self.suggest($3).map {|v| "#{$1}#{$2} #{v}"}
    when /^(beginning|end)? ?(\d+|this|last) *$/
      ["day","days","week","weeks","year","years","hour","hours","month","months"].map {|v| "#{text} #{v}"}
    when /^(\d+|from|this|last) (beginning|end)? ?(day|days|week|weeks|year|years|hour|hours) *$/
      ["ago","from now"].map {|v| "#{text} #{v}"}
    else
      []
    end
  end
  
end

class String

  alias_method :orig_to_time, :to_time
  def to_time(from = Time.now)
    if self =~ /(from )?(the )?(.*) (-|to|until|till|up to) (the )?(.*)/
      first = $3.to_time(from)
      second_str = $6
      if second_str =~ /^(.*) later$/
	return first.."#{$1} from now".to_time(first)
      else
	return first..second_str.to_time(from)
      end
    end
    
    correction = :none

    case self
    when /^(at )?begin(ning)? (of )?(.*)$/
      correction = :beginning
      str = $4
    when /^(at )?end(ing)? (of )?(.*)$/
      correction = :end
      str = $4
    else
      str = self
    end
   
    time = nil

    case str
    when "today"
      num = 0
      span = "day"
      direction = "ago"
    when "yesterday"
      num = 1
      span = "day"
      direction = "ago"
    when /^(\d+|last|this|the)? ?(day|days|week|weeks|year|years|month|months|hour|hours) ?(ago|from now)?$/
      direction = ($3 or "ago")
      direction = "from_now" if direction == "from now"
      span = $2.singularize      

      case $1
      when "last"
	raise "'#{$3}' does not make sense with 'last'." if $3
	num = 1
      when "this","the"
	raise "'#{$3}' does not make sense with 'this'." if $3
	num = 0
      when nil
	num = 0
      else
	raise "Please add a direction 'ago' or 'from now' to the end #{$3}." unless $3	
	num = $1.to_i
      end
    else
      begin
	time = orig_to_time
	case time.strftime("%T")
	when /00:00:00$/
	  span = "day"
	when /00:00$/
	  span = "hour"
	else
	  span = "minute"
	end
      rescue ArgumentError
	raise "Date not recognized '#{self}' ."
      end
    end

    time = num.send(span).send(direction,from.to_time) unless time

    case correction
    when :beginning
      time.send("beginning_of_#{span}")
    when :end
      time.send("end_of_#{span}")
    else
      time
    end
  end

  def to_time_range(from = Time.now)
    v = self.to_time(from)
    if v.class == Range
      v
    else
      "beginning of #{self} until end of #{self}".to_time(from)
    end
  end

  def to_time_range_str(from = Time.now)
    res = self.to_time_range(from)
    res.first.strftime("%F %T")..res.last.strftime("%F %T")
  end

  def to_time_str(from = Time.now)
    res = to_time(from)
    if res.class.name == "Range"
      res.first.strftime("%F %T")..res.last.strftime("%F %T")
    else
      res.strftime("%F %T")
    end
  end
    
end
    
