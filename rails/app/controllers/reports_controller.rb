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

class ReportsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @reports = Report.paginate :page => params[:page], :order => "id DESC"
  end

  def show
    @image_url = url_for(:controller => "charts", 
	:action => "chart_image") + "?"
    @report = Report.find(params[:id])
    @chart_options = {
	:url => url_for(:controller => "charts", 
			:action => "chart_image") + "?"}
#    begin
#      raise "View not found." unless @report.original_report_template.view
#      table = @report.original_report_template.view.table.table_name
#      @chart_options[:link] = url_for(:controller => "survey",
#				      :action => "chart_click",
#				      :table => table) + "?"
#    rescue
#      flash[:warning] = "Could not create chart link: '#{$!}'"
#    end
    
    begin
      @report_text = @report.text(@chart_options) 
    rescue
      @report_text = "<span class='error'>'#{$!}'</span>"
    end
  end

  def send_to_email
    @report = Report.find(params[:id])
    @email_types = ["normal","simple"]
  end

  def deliver_to_email
    raise "No address given." unless params[:addresses]
    raise "No type given" unless params[:type]
    @report = Report.find(params[:id])
    ReportMailer.send("deliver_#{params[:type]}", params[:addresses], @report)
  end


  def email_preview
    @report = Report.find(params[:id])
    m = ReportMailer.send("create_#{params[:type]}",nil,@report, {:preview => true})
    render :text => "<html><body>#{BaseMailer.preview_html(m)}</body></html>"
  end

  def new
    raise "not implemented"
    @report = Report.new
  end

  def create
    raise "not implemented"
    @report = Report.new(params[:report])
    if @report.save
      flash[:notice] = 'Report was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    raise "Cannot edit a report."
    @report = Report.find(params[:id])
  end

  def update
    raise "not implemented"
    @report = Report.find(params[:id])
    if @report.update_attributes(params[:report])
      flash[:notice] = 'Report was successfully updated.'
      redirect_to :action => 'show', :id => @report
    else
      render :action => 'edit'
    end
  end

  def destroy
    Report.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def get_data
    @report = Report.find(params[:id])
    obj = @report.objects[params[:number].to_i]
    send_data(obj.to_csv,
	      :type => 'text/csv; charset=iso-8859-1; header=present',
	      :filename => safe_filename("#{@report.name}_#{@report.id}_#{obj.class.name}_#{obj.name}","csv",@report.date))

  end
end
