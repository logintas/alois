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

# overwrite reset_column_information, would fail for column count(*)

module ActiveRecord
  class Base
    def self.reset_column_information
      
      generated_methods.each { |name| 
        begin
          undef_method(name)
        rescue
          $log.warn("Undef method #{name} failed: #{$!}")
        end
      }
      @column_names = @columns = @columns_hash = @content_columns = @dynamic_methods_hash = @generated_methods = @inheritance_column = nil
      
    end
  end
end
