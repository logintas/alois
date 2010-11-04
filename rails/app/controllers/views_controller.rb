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

class ViewsController < ApplicationController
  include ApplicationHelper
  before_filter :handle_cancel, :only => [ :new, :create, :update ]

  private
  def handle_cancel
    if params[:commit] == "Cancel"
      redirect_to :action => :list
    end
  end

  public
  def index
    redirect_to :action => :list
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @views = View.find(:all).select {|view| view.exclusive_for_group.nil? or view.exclusive_for_group == "" or view.exclusive_for_group == group}
  end

  def show
    @view = View.find(params[:id])
  end

  def show_inline
    @view = View.find(params[:id])
    render :layout => false
  end

  def new
    @view = View.new
    @view = View.from_zip(params[:view_zip]) if params[:view_zip]
  end

  def create
    begin
      @view = View.new(params[:view])
      if @view.save
	flash[:notice] = 'View was successfully created.'
	redirect_to :action => 'list'
      else
	p @view.errors
	render :action => 'new'
      end
    rescue
      p $!.message
      flash[:error] = $!.message
      render :action => 'new'
    end
  end

  def edit
    @view = View.find(params[:id])
  end

  def update
    begin
      @view = View.find(params[:id])
      if @view.update_attributes(params[:view])
	flash[:notice] = 'View was successfully updated.'
	redirect_to :action => 'list', :id => @view
      else
	render :action => 'edit'
      end
    rescue
      flash[:error] = $!.message
      render :action => 'edit'
    end
  end

  def destroy
    View.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

end
