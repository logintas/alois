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

class SwissmentorDataMeta < ActiveRecord::Base

  description "Swissmentor Logs"
  sources ["SwissmentorBaseMeta"]
  def self.expressions
    ret = []

    # 'MOVE Object "%s" #%d to #%d',[ aObject.Name ,aObjectID, aNewParentID]
    ret.push({ :regex => /^(MOVE) (Object) \"([^\"]*)\" \#(\-?\d+) to #(\-?\d+)$/,
               :fields => [:action, :object_type, :object_name, :object_id, :parent_object_id]})

    # '%s %s #%d "%s" %s',[RightToString(Action),aObject.ObjectType,objectid,aObject.Name,AccessDenied]
    ret.push({ :regex => /^([A-Z]+) (.*) \#(\-?\d+) \"([^\"]*)\" (.*)$/,
               :fields => [:action, :object_type, :object_id, :object_name, :access]})

    # 'Set File Editing Objectid #'+inttostr(FileObjectID)
    ret.push({ :regex => /^(Set File Editing) Objectid #(\-?\d+)$/,
               :fields => [:action, :object_id]})

    # 'Change Status objectid ' + IntToStr(objectid));
    ret.push({ :regex => /^(Change Status) objectid (\-?\d+)$/,
               :fields => [:action, :object_id]})
    
    # 'CHANGE STATUS #' + IntToStr(objectid) + ' with his childs');
    ret.push({ :regex => /^(CHANGE STATUS) #(\-?\d+)( with his childs)$/,
               :fields => [:action, :object_id],
               :result_filter => lambda {|results, instance| results[0] += results.pop; results }
             })

    # 'Delete Link of Object #%d to #%d',[ objectid, parentobjectid]
    ret.push({ :regex => /^(Delete Link of Object) #(\-?\d+) to #(\-?\d+)$/,
               :fields => [:action, :object_id, :parent_object_id]  })

    # 'Delete objectid ' + IntToStr(objectid)+' by ' + user
    ret.push({ :regex => /^(Delete objectid|Delete file id) (\-?\d+) by (.*)$/,
               :fields => [:action, :object_id],
               :result_filter => lambda {|results, instance|       
                 if results[2] != instance.client_user
                   raise "User not equal #{results.inspect} #{instance.inspect}"
                   #results[0] += results.pop
                 end
                 results.pop
                 results
               }})

    # 'delete objectid ' + IntToStr(objectid) + ' with his childs');
    ret.push({ :regex => /^(delete objectid) (\-?\d+)( with his childs)$/,
               :fields => [:action, :object_id],
               :result_filter => lambda {|results, instance| 
                 results[0] += results.pop;
                 results }
             })
    
    # 'Removed Lock for Object %d',[Objectid]
    ret.push({ :regex => /^(Removed Lock for Object) (\-?\d+)$/,
               :fields => [:action, :object_id] })
    
    # 'Lock Object %d',[Objectid]));
    ret.push({ :regex => /^(Lock Object) (\-?\d+)$/,
               :fields => [:action, :object_id] })

    # 'Starting export of object %d',[ObjectId]
    ret.push({ :regex => /^(Starting export of object) (\-?\d+)$/,
               :fields => [:action, :object_id] })

    # 'Export of object %d succeeded',[ObjectId]
    # 'Export of object %d failed',[ObjectId]
    ret.push({ :regex => /^(Export of object) (\-?\d+)( succeeded| failed)$/,
               :fields => [:action, :object_id],
               :result_filter => lambda {|results, instance| results[0] += results.pop; results }
             })

    return ret
  end
  
end

