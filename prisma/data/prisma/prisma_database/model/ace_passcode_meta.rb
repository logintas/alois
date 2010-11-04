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

  class AcePasscodeMeta < ActiveRecord::Base
    
    description "Meta information about passcodes on ace server."
    sources ["WindowsEventMeta","LogMeta"]
    def self.may_have_messages?; false; end
    
    preseed_expression /^(.{1,40}) \(Login:\'([^\']*)\'; User Name:\'([^\']*)\'; Token:\'([^\']*)\'; Group:\'([^\']*)\'; Site:\'([^\']*)\'; Agent Host:\'([^\']*)\'; Server:\'([^\']*)\'\). *$/
    
    def self.expressions
      [{ :regex => /^(.*) \(Login:\'([^\']*)\'; User Name:\'([^\']*)\'; Token:\'([^\']*)\'; Group:\'([^\']*)\'; Site:\'([^\']*)\'; Agent Host:\'([^\']*)\'; Server:\'([^\']*)\'\). *$/,
	  :fields => [:action, :login, :user_name, :token, :group_name, :site, :agent_host, :server]}]
    end
    
  end
