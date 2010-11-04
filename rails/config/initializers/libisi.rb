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


#mode = :real
mode = :simple

# Initialize Libisi unless it
# has already been initialized
unless defined?(LIBISI)
  # Initialize libisi
  case mode
  when :simple
    # simple way
    $log = RAILS_DEFAULT_LOGGER
  when :real  
    require 'libisi'
    init_libisi(:log_levels => [:DEBUG, :INFO, :PERF, :WARN, :ERROR, :FATAL])  
  end
  $log.info("Libisi functions enabled")
end

=begin
#LIBISI Stuff
#  Dispatcher.before_dispatch {|dispatcher|
#    p "Libisi"
#  }
end

def define_new_logger(name = nil)
  $log.info{"Define new logger '#{name}'."}  
  if Log.outputs[0] == :stdout
    output = :stdout
    pattern = Log::LOG_FORMAT.sub("::",":#{name}:")
  else
    pattern = nil
    output= File.join(RAILS_ROOT,'log',name + '.log')
  end
  Log.redefine_logger(:output => output, :pattern => pattern)  
end
=end



#$log = RAILS_DEFAULT_LOGGER
#RAILS_DEFAULT_LOGGER.level = Logger.const_get(LOG_LEVEL.to_s.upcase) if defined?(LOG_LEVEL)
#RAILS_DEFAULT_LOGGER.level = Logger.const_get(ENV["LOG_LEVEL"].to_s.upcase) if ENV["LOG_LEVEL"]
#$log = RAILS_DEFAULT_LOGGER


# $log is used in prisma
#$log = RAILS_DEFAULT_LOGGER

