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

class ChartsController < ApplicationController
  include ApplicationHelper
  include SurveyHelper
  before_filter :handle_cancel, :only => [ :new, :create, :update ]
  before_filter :init
  
  private
  def init
    initialize_parameters
  end

  def handle_cancel
    if params[:commit] == "Cancel"
      redirect_to :action => :list
    end
  end
  
  public
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :destroy, :create, :update, :render_chart ],
#         :redirect_to => { :action => :list }

  def list
    @charts = Chart.find :all
  end

  def show
    @chart = Chart.find(params[:id])
  end

  def render_chart
    @chart = Chart.find(params[:id])
    redirect_to :controller => "survey", :action => "chart", 
      :chart_id => @chart.id, :state_id => @state_id, :table => current_datasource.table.table_name
#    @chart.datasource = current_datasource
#    if @chart.datasource
#      @chart.render
#    end
  end

  def render_chart_inline
    render_chart
    render :partial => "render_chart_inline"
  end

  def chart_image
    @chart = Chart.find(params[:id]) if params[:id]

    if @chart.mode == :view_only
      raise "Preview not allowed for view_only chart" if params[:preview]
      raise "Recreate data not allowed for view_only chart" if params[:recreate_data]
    else
      @chart.mode = :preview if params[:preview]
      @chart.datasource = current_datasource
      @chart.render(:recreate_data => params[:recreate_data]) if @chart.datasource
    end

    headers['Cache-Control'] = 'no-cache, must-revalidate'
    send_file( @chart.png_file_name,
	      :disposition => 'inline',
	      :type => 'image/png', 
	      :filename => @chart.image_name)
  end


  def show_inline
    render :layout => false
  end

  def new
    initialize_parameters
    if @chart
      @chart = @chart.full_clone
      @chart.mode = nil
      @chart.datasource = current_datasource
    else
      @chart = Chart.new
    end
    
    @chart.attributes = params[:chart] if params[:chart]
    save_session
  end

  def edit_inline
    render :partial => "form"
  end

  def edit
    @chart = Chart.find(params[:id])    
  end

  def create
    @chart = Chart.new(params[:chart])
    @chart.datasource = current_datasource
    
    if @chart.save
      flash[:notice] = 'Chart was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def update
    @chart = Chart.find(params[:id])    
    if @chart.update_attributes(params[:chart])
      flash[:notice] = 'Chart was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Chart.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  def auto_complete_for_chart_time_range
    render :inline => "<%= content_tag(:ul, Time.suggest(params[:chart][:time_range]).map { |org| content_tag(:li, h(org)) }) %>"
  end

end
