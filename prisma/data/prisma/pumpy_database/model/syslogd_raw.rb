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

  class SyslogdRaw < ActiveRecord::Base

    # kernel = 0, user = 1, mail = 2, ...
    FACILITIES = ["kernel","user","mail","system","auth"]
    
    # emerg = 0, alert = 1, ...
    LEVELS = ["emerg","alert","crit","err","warning","notice","info","debug"]
    
    PRIORITIES = ["emerg","alert","cirt","err","warning","notice","info","debug","none"]


    description "Syslogd raw record on pumpy."    

    attr_accessor :origin

    def self.create_random_test_message(date_time = nil)
      date_time ||= DateTime.now
      
      SyslogdRaw.create(:ip => "127.0.0.111",
			:host => "testhost",
			:facility => FACILITIES.rand,
			:priority => PRIORITIES.rand,
			:level => LEVELS.rand,
			:tag => "",
			:date => date_time.strftime("%F"),
			:time => date_time.strftime("%T"),
			:program => "Alois Random",
			:msg => "Alois random genearated log.")
    end
    
    def to_s
      "SyslogdRaw.#{id} #{@origin}"
    end
  end
