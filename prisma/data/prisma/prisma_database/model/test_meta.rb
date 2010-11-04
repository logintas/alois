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

  class TestMeta < ActiveRecord::Base
    
    description "Testing class"
    sources ["PureMeta", "LogMeta"]

    preseed_expression /^(PRISMA THROW EXCEPTION)$/

    def initialize(parent, values)
      super()
      self.message = values[:test_msg]
      self.save
      throw "#{values[:test_msg]} This error is ok. Its for stability testing."
    end
    
    def self.expressions
      ret = []

      ret.push({ :regex => /^(PRISMA THROW EXCEPTION)$/,
        :fields => [:test_msg]})
    end

  end
