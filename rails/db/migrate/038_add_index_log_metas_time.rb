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

class AddIndexLogMetasTime < ActiveRecord::Migration
  def self.up
    # add index log_metas_time_index
    if LogMeta.connection.indexes(:log_metas).select {|i|i.columns == ["time"]}.length == 0
      add_index :log_metas, :time
    end
  end

  def self.down
    # remove index log_metas_time_index
    remove_index :log_metas, :time
  end
end
