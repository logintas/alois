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

class SentinelsController < ApplicationController
  before_filter :handle_cancel, :only => [ :create, :update ]

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
    @sentinels = Sentinel.find(:all, :order => "action desc,alarm_level,name")
  end

  def show
    @sentinel = Sentinel.find(params[:id])
  end

  def new
    @sentinel = (load_current_object or Sentinel.new)
  end

  def create
    @sentinel = Sentinel.new(params[:sentinel])
    begin
      if @sentinel.save
        flash[:notice] = 'Sentinel was successfully created.'
	@sentinel.errors.each {|attribute,text|
	  flash[:warning] = text
	}
        redirect_to :action => 'list'
      else
        render :action => 'new'
      end
    end
  end

  def manually_execute
    @sentinel = Sentinel.find(params[:id])
    alarm,report = @sentinel.process
    if alarm
      flash[:notice] = 'Sentinel produced this alarm.'
      redirect_to :controller => "alarms", :action => "show", :id => alarm
    else
      if report
	flash[:notice] = 'Sentinel produced this report.'
	redirect_to :controller => "reports", :action => "show", :id => report
      else
	flash[:notice] = 'Sentinel did not produce an alarm or a report.'
	redirect_to :action => "show", :id => @sentinel
      end
    end    
  end

  def edit
    @sentinel = Sentinel.find(params[:id])
  end

  def update
    @sentinel = Sentinel.find(params[:id])
    if @sentinel.update_attributes(params[:sentinel])
      flash[:notice] = 'Sentinel was successfully updated.'
      @sentinel.errors.each {|attribute,text|
	flash[:warning] = text
      }
      redirect_to :action => 'show', :id => @sentinel
    else
      render :action => 'edit'
    end
  end

  def destroy
    Sentinel.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def auto_complete_for_sentinel_time_range
    render :inline => "<%= content_tag(:ul, Time.suggest(params[:sentinel][:time_range]).map { |org| content_tag(:li, h(org)) }) %>"
  end
end
