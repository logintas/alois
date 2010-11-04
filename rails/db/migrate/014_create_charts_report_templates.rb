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

class CreateChartsReportTemplates < ActiveRecord::Migration
  def self.up
    create_table :charts_report_templates do |t|
      t.column :priority, :integer
      t.column :chart_id, :integer
      t.column :report_template_id, :integer
      t.column :view_id, :integer
    end

    add_index "charts_report_templates", ["chart_id"]
    add_index "charts_report_templates", ["report_template_id"]
    add_index "charts_report_templates", ["view_id"]

  end

  def self.down
    drop_table :charts_report_templates
  end
end
