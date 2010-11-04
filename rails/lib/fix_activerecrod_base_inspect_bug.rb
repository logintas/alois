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

# this seems not to work
# essential is the "rescue false"

# /usr/share/alois/www/vendor/rails/activerecord/lib/active_record/base.rb:1153
module ActiveRecord
  class Base
    # Returns a string like 'Post id:integer, title:string, body:text'
    def self.inspect
      if self == Base
	super
      elsif abstract_class?
	"#{super}(abstract)"
      elsif (table_exists? rescue false)
	attr_list = columns.map { |c| "#{c.name}: #{c.type}" } * ', '
	"#{super}(#{attr_list})"
      else
	"#{super}(Table doesn't exist or no connection)"
      end
    end
  end
end
