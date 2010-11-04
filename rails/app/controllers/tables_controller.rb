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

class TablesController < ApplicationController
  before_filter :initialize_parameters

  # GET /tables
  # GET /tables.xml
  def index
    @tables = Table.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tables }
    end
  end

  def list
    redirect_to :action => :index
  end

  # GET /tables/1
  # GET /tables/1.xml
  def show
    @table = Table.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @table }
    end
  end

  # GET /tables/new
  # GET /tables/new.xml
  def new
    @table = Table.new
  end

  # GET /tables/1/edit
  def edit
    @table = Table.find(params[:id])
  end

  # POST /tables
  # POST /tables.xml
  def create
    @table = Table.new(params[:table])
    
    if @table.save
      flash[:notice] = 'Table was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  # PUT /tables/1
  # PUT /tables/1.xml
  def update
    @table = Table.find(params[:id])    
    if @table.update_attributes(params[:table])
      flash[:notice] = 'Table was successfully updated.'
      redirect_to :action => 'show', :id => @table
    else
      render :action => 'edit'
    end
  end

  # DELETE /tables/1
  # DELETE /tables/1.xml
  def destroy
    @table = Table.find(params[:id])
    @table.destroy

    respond_to do |format|
      format.html { redirect_to :action => "list" }
      format.xml  { head :ok }
    end
  end

  def render_table
    @table = Table.find(params[:id])
    @datasource, @conditions = parse_datasource_parameters
    @table.datasource = @datasource
    @table.conditions = @conditions
        
    @table.remove_cache
    @count = @table.count
    @data =(@table.as(params[:type].to_sym, :ignore_table_width => true) or "NO DATA")
  end

end
