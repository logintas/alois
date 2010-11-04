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

  class ApacheLogMeta < ActiveRecord::Base

    description "Additional apache metas for a apache message over pure."

    def self.may_have_messages?; false; end
        
    def self.create_table()
      connection.create_table table_name do |t|
	t.column :forensic_id, :string, :limit => 30
	t.column :serve_time, :integer
        t.column :host, :string, :limit => 50
    end
      $log.info "Created table #{table_name}." if $log.info?
    end
  end

