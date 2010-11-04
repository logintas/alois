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

class IpRangesController < ApplicationController

  # GET /ip_ranges
  # GET /ip_ranges.xml
  def index
    @ip_ranges = IpRange.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ip_ranges }
    end
  end

  # GET /ip_ranges/1
  # GET /ip_ranges/1.xml
  def show
    @ip_range = IpRange.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ip_range }
    end
  end

  # GET /ip_ranges/new
  # GET /ip_ranges/new.xml
  def new
    @ip_range = IpRange.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ip_range }
    end
  end

  # GET /ip_ranges/1/edit
  # POST /ip_ranges/1/edit
  def edit
    @ip_range = IpRange.find(params[:id])
  end

  # POST /ip_ranges
  # POST /ip_ranges.xml
  def create
    @ip_range = IpRange.new(params[:ip_range])

    respond_to do |format|
      if @ip_range.save
        flash[:notice] = 'IpRange was successfully created.'
        format.html { redirect_to(@ip_range) }
        format.xml  { render :xml => @ip_range, :status => :created, :location => @ip_range }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ip_range.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ip_ranges/1
  # PUT /ip_ranges/1.xml
  def update
    @ip_range = IpRange.find(params[:id])

    respond_to do |format|
      if @ip_range.update_attributes(params[:ip_range])
        flash[:notice] = 'IpRange was successfully updated.'
        format.html { redirect_to(@ip_range) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ip_range.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ip_ranges/1
  # DELETE /ip_ranges/1.xml
  def destroy
    @ip_range = IpRange.find(params[:id])
    @ip_range.destroy

    respond_to do |format|
      format.html { redirect_to(ip_ranges_url) }
      format.xml  { head :ok }
    end
  end
end
