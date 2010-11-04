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

class ExtendPostfixTable < ActiveRecord::Migration
  def self.up
    add_column "postfix_detail_metas", "relay_port", :integer
    change_column "postfix_detail_metas", "delay", :float
    rename_column "postfix_detail_metas", "command", "result_text"
    add_column "postfix_detail_metas", "delay_before_qmgr", :float
    add_column "postfix_detail_metas", "delay_in_qmgr", :float
    add_column "postfix_detail_metas", "delay_conn_setup", :float
    add_column "postfix_detail_metas", "delay_transmission", :float
    add_column "postfix_detail_metas", "dsn", :string, :limit => 10
    add_column "postfix_detail_metas", "result", :string, :limit => 20
    add_column "postfix_detail_metas", "result_mail_id", :string, :limit => 10
  end

  def self.down
    remove_column "postfix_detail_metas", "relay_port"
    change_column "postfix_detail_metas", "delay", :integer
    rename_column "postfix_detail_metas", "result_text","command"
    remove_column "postfix_detail_metas", "delay_before_qmgr"
    remove_column "postfix_detail_metas", "delay_in_qmgr"
    remove_column "postfix_detail_metas", "delay_conn_setup"
    remove_column "postfix_detail_metas", "delay_transmission"
    remove_column "postfix_detail_metas", "dsn"
    remove_column "postfix_detail_metas", "result"
    remove_column "postfix_detail_metas", "result_mail_id"
  end
end
