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

module AloisHelper

  def alois_menu
    common_menu
  end

  def navigation_bar
    

    @navigation=[]

    @navigation.push({ :title => 'Home', :url => url_for( :controller => 'prisma', :action => 'overview')})

    @navigation.push({ :title => 'Statistics', :url => url_for( :controller => 'prisma', :action => 'statistics')})

    sub_entries=[]
    for view in View.find(:all, :order => 'name')
      sub_entries.push({ :title => view.name , :url => url_for( :controller => 'survey', :action => 'list', :table => view.view_name ) })
    end

    @navigation.push({ :title => 'Views', :url => url_for( :controller => 'views'), :submenu => sub_entries })

    sub_entries=[]
    for klass in Prisma::Database.get_classes(:meta).sort{ |x,y| ((x.name <=> y.name) == 0) ? x.description <=> y.description : x.name <=> y.name }
      sub_entries.push({ :title => klass.description, :url => url_for( :controller => 'survey', :action => 'list', :table => klass.table_name ) })
    end
    @navigation.push({ :title => 'Tables', :url => url_for( :controller => 'tablelist'), :submenu => sub_entries })

    sub_entries=[]
    for filter in Filter.find(:all)
      sub_entries.push({ :title => filter.name, :url => url_for( :controller => 'filters', :action => 'show', :id => filter ) })
    end
    @navigation.push({ :title => 'Filters', :url => url_for( :controller => 'filters' ), :submenu => sub_entries })

    sub_entries=[]
    for sentinel in Sentinel.find(:all)
      sub_entries.push({ :title => sentinel.name, :url => url_for( :controller => 'sentinels', :action => 'show', :id => sentinel ) })
    end
    @navigation.push({ :title => 'Sentinels', :url => url_for( :controller => 'sentinels' ), :submenu => sub_entries })
    return @navigation
  end


  # Output helper
  def title(title)
    return "<h1>#{h(title)}</h1>"
  end

end
