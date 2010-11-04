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

# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include ApplicationHelper
  helper :alarms
#  around_filter :catch_exceptions
    
  private
  def catch_exceptions
    yield
  rescue => exception
    render_text "<pre>#{$!}</pre>",:layout => true  
  end

  public  

  def local_request?
    false
  end

  def rescue_action_in_public(exception)
    @exception = exception
    @exception_name = exception.class.to_s.underscore
    if (@template.pick_template_extension("exception/#{@exception_name}") rescue nil)
      render :partial => "exception/#{@exception_name}", :layout => true
    else
      render :partial => "exception/generic", :layout => true
    end
  end


  if $selected_theme.respond_to?(:helper) then 
    helper :application, $selected_theme.helper 
  end
  
  if $selected_theme and $selected_theme.respond_to?(:layout) and $selected_theme.layout
    layout  $selected_theme.layout
  end

  def render(options = nil, &block)
    if params[:layout] == "false"
      options ||= {}
      options[:layout] ||= false
    end
    super
  end
  
  def auto_complete_for_condition_value    
    render :inline => "<%= content_tag(:ul, Time.suggest(params[:condition][:value]).map { |org| content_tag(:li, h(org)) }) %>"
  end

  FLASH_COLORS = {:info => "green",
    :warning => "orange",
    :error => "red"}

  def flash_text
    (flash || {}).map {|key,val|
      "<p style='color: #{FLASH_COLORS[key] || "orange"}'>#{val}</p>"
    }.join
  end

end
