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

class ReportTemplatesController < ApplicationController
  include ApplicationHelper
  before_filter :handle_cancel, :only => [ :new, :create, :update ]
  before_filter :initialize_parameters

  private
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
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @report_templates = ReportTemplate.paginate :page => params[:page]
  end

  def show
    @report_template = ReportTemplate.find(params[:id])
    @report_template.delete_cache if params[:delete_cache]

    if params[:render] or @report_template.cache_exist?
      @preview = true

      @datasource, @conditions = parse_datasource_parameters

      @options = {
	:url => url_for(:controller => "charts", 
			:action => "chart_image") + "?"      }      
      
      @options[:datasource] = @datasource
      @options[:conditions] = @conditions

      case params[:commit]
      when "Save as Report"
	@report_template.delete_cache
	@report = Report.generate(@report_template,user, @options)
	redirect_to :controller => "reports", :action => "show", :id => @report
      when "Preview with real data"
#	@report_template.mode = :real
	@report_template.delete_cache
	@report_template.render(@options)
      when "Preview with fake data"
	@report_template.delete_cache
	@report_template.mode = :preview
	cols = @datasource.table.columns.map{|c| c.name}
	cols += ["data"] # for chart preview always a data col is needed
	raise "No cols in view." if cols.length == 0
	@datasource = RandomDatasource.new(cols)
	@options[:datasource] = @datasource

	@report_template.render(@options)
      when nil
	@report_template.mode = :preview	
      else
	raise "Unknown preview mode '#{params[:preview]}'."
      end
      
    end
    @report_template.mode = :preview if @preview
  end

  def new
    @report_template = (load_current_object or ReportTemplate.new)
  end

  def create
    @report_template = ReportTemplate.new(params[:report_template])
    if @report_template.save
      flash[:notice] = 'ReportTemplate was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @report_template = ReportTemplate.find(params[:id])
  end

  def update
    @report_template = ReportTemplate.find(params[:id])
    if @report_template.update_attributes(params[:report_template])
      flash[:notice] = 'ReportTemplate was successfully updated.'
      redirect_to :action => 'show', :id => @report_template
    else
      render :action => 'edit'
    end
  end

  def add_chart
    @report_template = ReportTemplate.find(params[:id])
    @chart = Chart.find(params[:chart])
    @report_template.charts << @chart
    redirect_to :action => "show", :id => @report_template
  end
  
  def remove_chart
    @report_template = ReportTemplate.find(params[:id])
    @chart = Chart.find(params[:chart])
    @report_template.charts.delete(@chart)
    redirect_to :action => "show", :id => @report_template
  end

  def add_table
    @report_template = ReportTemplate.find(params[:id])
    @table = Table.find(params[:table])
    @report_template.tables << @table
    redirect_to :action => "show", :id => @report_template
  end
  
  def remove_table
    @report_template = ReportTemplate.find(params[:id])
    @table = Table.find(params[:table])
    @report_template.tables.delete(@table)
    redirect_to :action => "show", :id => @report_template
  end

  def destroy
    ReportTemplate.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
