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

class AlarmsController < ApplicationController
  include ApplicationHelper
  
  def index
    status
    render :action => 'status'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def status
    @alarms = Alarm.paginate :page => params[:page], :order => "alarm_level, created_at DESC", :per_page => 10,
      :conditions => Alarm::ACTIVE_YELLOW_RED_CONDITION
    @infos = Alarm.paginate :page => params[:page_info], :per_page => 10, :order => "id DESC",
      :conditions => Alarm::ACTIVE_WHITE_CONDITION
    @ack_alarms = Alarm.paginate :page => params[:page_ack], :limit => 10, :per_page => 10, :order => "id DESC",
      :conditions => Alarm::ACKNOWLEDGE_CONDITION
  end

  def list
    status
    render :action => 'status'
  end

  def listing    
    @alarms = Alarm.paginate :page => params[:page], :order => "id DESC"
    render :action => 'list'
  end

  def show
    @alarm = Alarm.find(params[:id])
  end

  def new
    @alarm = Alarm.new
  end

  def create
    @alarm = Alarm.new(params[:alarm])
    if @alarm.save
      flash[:notice] = 'Alarm was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @alarm = Alarm.find(params[:id])
  end

  def update
    @alarm = Alarm.find(params[:id])
    params[:alarm] = {} unless params[:alarm]
    params[:alarm][:updated_by] = user
    if @alarm.update_attributes(params[:alarm])
      flash[:notice] = 'Alarm was successfully updated.'
      redirect_to :action => 'show', :id => @alarm
    else
      render :action => 'edit'
    end
  end

  def destroy
    raise "Not supported"
    Alarm.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def survey_component
    @alarm_pages, @alarms = paginate :alarms, :per_page => 10, :order => "id DESC"    
    render :partial => "survey_component"
  end

  # ACL: admin
  def send_to_email
    raise "No address given." unless params[:addresses]
    @alarm = Alarm.find(params[:id])
    AlarmMailer.deliver_simple(params[:addresses], @alarm)
  end

end
