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

  # Condition for matching against date columns
  class DateCondition < Condition

    # For usage in UI
    def self.get_date_descriptions
      values_help_text.keys.map { |v| v.to_s }
    end
    # Descriptions for special value parameters
    def self.values_help_text
      { :today => "The current date.",
	:yesterday => "The yesterday's date."
      }
    end

    # Returns the time range (converts a "prosa" value into a range, eg today)
    def range(options = {})
      value.to_time_range((options[:now] or Time.now)) 
    end

    # Returns true if value describes a whole day
    def exact_date?(options = {})
      from_date(options) == to_date(options)
    end

    # return quoted date
    def quoted_date(date, options = {})
      if table = options[:table_class]
        date = Time.parse(date.strftime("%F"))
        table.connection.quoted_date(date)
      else
        date.strftime("%F")
      end
    end

    # The starting date of the range
    def from_date(options = {})
      quoted_date(range(options).first, options)
    end

    # The starting time of the range
    def from_time(options = {})
      t = range(options).first.strftime("%T")
      return nil if t == "00:00:00"	
      t
    end

    # The ending date of the range
    def to_date(options = {})
      quoted_date(range(options).last, options)
    end
    
    # The ending time of the range
    def to_time(options = {})
      t = range(options).last.strftime("%T")
      return nil if t == "23:59:59"
      t
    end

    # Returns the SQL condition
    def sql(options = {})
      options = normalize_options(options)
      ret = ""

      if exact_date?(options)
	ret += "#{column} = '#{self.from_date(options)}' "
      else
	ret += "#{column} >= '#{self.from_date(options)}' AND "	
	ret += "#{column} <= '#{self.to_date(options)}' "	
      end

      raise "not time selection supported yet '#{range(options)}' please use beginning and end." if from_time or to_time

      return nil if ret == ""
      return ret
    end
    
  end
