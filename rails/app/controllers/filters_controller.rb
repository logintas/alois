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

class FiltersController < ApplicationController
  include ApplicationHelper
  before_filter :handle_cancel, :only => [ :new, :create, :update ]
  
  private
  def filter_class
    # otherwise rails filter class would be returned
    View.instance_eval("Filter")
  end

  def init
    initialize_parameters
    
    @table_class = Prisma::Database.get_class_from_tablename(@table_name) if defined?(Prisma::Database)
    @table_class = View.get_class_from_tablename(@table_name) unless @table_class
    @conditions = @current_filter.conditions if @current_filter

    if params[:id] and params[:id].to_s != @current_filter.id.to_s
      @current_filter = filter_class.find(params[:id])
    end
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
#  verify :method => :post, :only => [ :destroy, :create, :update, :update_condition ],
#         :redirect_to => { :action => :list }

  def list
    init
    @filters = filter_class.find(:all,:order => "name")
  end

  def show
    init
  end

  def show_inline
    init
    render :layout => false
  end

  def new
    init
    @current_filter = filter_class.new(:name => "new") if (@current_filter.nil? or !params[:use_current])
    @current_filter = filter_class.from_zip(params[:filter_zip]) if params[:filter_zip]
    save_session
  end

  def edit_inline
    init
    render :partial => "form"
  end

  def edit
    init
    @conditions = @current_filter.conditions()
    save_session
  end

  def create
    init
    if @current_filter
      @current_filter.update_attributes(params[:current_filter])
    else
      @current_filter = filter_class.new(params[:current_filter])
    end
    
    if @current_filter.save
#redo      flash[:notice] = 'filter_class was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def add_condition
    init
    @current_filter = filter_class.new unless @current_filter
    @current_filter.conditions = @current_filter.conditions << 
      Condition.create(params[:column], params[:operator], params[:value])

    if @current_filter.valid?      
      reset_paging
      save_session
    else
      @current_filter.conditions = @current_filter.conditions[0..-2]
      flash[:warning] = "Session not saved. New filter not valid."
    end
    render :partial => "form"
  end
  
  def remove_condition
    init
    @conditions[params[:condition_id].to_i..params[:condition_id].to_i] = []
    @current_filter.conditions = @conditions
    reset_paging
    save_session
    render :partial => "form"
  end

  def update_condition
    init
    c = @conditions[params[:condition_id].to_i]
    c.update_from_params(params[:condition])
    @conditions[params[:condition_id].to_i] = c
    @current_filter.conditions = @conditions

    if @current_filter.valid?
      reset_paging
      save_session
    else
      flash[:warning] = "Session not saved. New filter not valid."
    end

    render :partial => "form"    
  end

  def clear_current_filter
    init
    @current_filter = filter_class.new
    reset_paging
    save_session
    render :partial => "form_with_functions"
  end

  def update
    init
    if @current_filter.update_attributes(params[:current_filter])
      flash[:notice] = 'filter_class was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    init
    filter_class.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def add_inline
    init
    @current_filter = filter_class.create_from_params(params)
    @current_filter.save
    redirect_to :action => 'list_inline'
  end

  def destroy_inline
    init
    filter_class.find(params[:id]).destroy
    redirect_to :action => 'list_inline'
  end

  def list_possible_filters    
    initialize_parameters
    @filters = filter_class.find(:all,:order => "name").select {|f|
      f.valid_for_table?(current_datasource)
    }
    render :partial => "possible_filters"
  rescue
    render :text => $!.to_s
  end

end
