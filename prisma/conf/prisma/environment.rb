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

require "pathname"
ENV["GEM_HOME"] = nil if ENV["GEM_HOME"] and !Pathname.new(ENV["GEM_HOME"]).exist?
ENV["GEM_PATH"] = nil if ENV["GEM_PATH"] and !Pathname.new(ENV["GEM_PATH"]).exist?

unless defined?(ActiveRecord::Base)
  require "rubygems"
  gem('activerecord', "2.3.2")
  gem('activesupport', "2.3.2")
  require "activerecord"
end
$log.debug("Your running on activerecrod version: #{ActiveRecord::VERSION::STRING}")

ActiveRecord::Base.logger = $log #Logger.new(File.open('database.log', 'a'))
require 'yaml'

unless defined?(PRISMA_ENV)
  if __FILE__.to_s == "/etc/prisma/environment.rb"
    PRISMA_ENV = (ENV["PRISMA_ENV"] or "production")
  else
    PRISMA_ENV = (ENV["PRISMA_ENV"] or "development")
  end
end
ENV["PRISMA_ENV"] = PRISMA_ENV

$log.info("PRISMA_ENV = #{PRISMA_ENV}")

env_file =  Pathname.new(__FILE__).dirname + "environment_#{PRISMA_ENV}.rb"
require env_file if env_file.exist?

PRISMA_ROOT = Pathname.new(__FILE__).dirname + "../.." unless defined?(PRISMA_ROOT)
PRISMA_LOG_DIR = PRISMA_ROOT + "log" unless defined?(PRISMA_LOG_DIR)
PRISMA_ARCHIVE = PRISMA_ROOT + "archive" unless defined?(PRISMA_ARCHIVE)
PRISMA_LIB_PATH = PRISMA_ROOT + "lib" unless defined?(PRISMA_LIB_PATH)
PRISMA_LOG = PRISMA_ROOT + "log" unless defined?(PRISMA_LOG)
PRISMA_CONFIG_PATH = Pathname.new(__FILE__).dirname

local_data = Pathname.new(__FILE__).dirname + "../../data/prisma"
global_data = Pathname.new("/usr/share/prisma/")
if local_data.exist?
  PRISMA_DATA_PATH = local_data
else
  PRISMA_DATA_PATH = global_data
end  

$archive_pattern =  PRISMA_ROOT + "archive/%t/%i/%d.arch" unless $archive_pattern

unless defined?(RAILS_ENV)
  alois_lib = (Pathname.new(__FILE__).dirname + "../../../rails/lib/")
  $:.push(alois_lib.to_s) if alois_lib.exist?
  require "alois/utils.rb"
  require "alois/date_time_enhance.rb"
end
$:.push(PRISMA_LIB_PATH.to_s) if PRISMA_LIB_PATH.exist?
require "prisma.rb"

MAX_QUEUE_SIZES = {"syslogd_raws" => 1000000}

# do not run prisma by default
$do_not_run_prisma = true

# delete logs in the database before:
$delete_logs_before = 3.months.ago

