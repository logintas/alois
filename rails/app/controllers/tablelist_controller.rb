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

class TablelistController < ApplicationController
  include ApplicationHelper

  def index
  end

  # Return the record count for a table
  def count
    begin
      klass = Prisma::Database.get_class_from_tablename(params[:table_name])
      throw "Class for table #{params[:table]} not found." unless klass
      @count = klass.approx_count
    rescue
      @count = "N/A <!-- #{$!.message} -->"
    end

    # Render without layout as it is used inline
    render(:layout => false)
  end

  def schema
    initialize_parameters
    @global_source_class = LogMeta #SourceDbMeta
    @record = current_table.find(params[:id]) if params[:id]

    p = @record
    @child_path = [p]
    while !p.nil? and (p.class.name != @global_source_class.name)
      (p = p.parent)
      @child_path.push(p)
    end
#    throw @child_path.map{|n| n.class.name}

    @parent_path = []
    while !p.nil?
      @parent_path.push(p)
      p = p.parent
    end

    if @parent_path.length == 0
      @parent_path = @child_path
      @child_path = []
    else
      @child_path.reverse!
    end
  end
end
