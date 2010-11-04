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

class BookmarksController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @bookmarks = Bookmark.paginate :page => params[:page]
  end

  def show
    @bookmark = Bookmark.find(params[:id])
  end

  def go
    @bookmark = Bookmark.find(params[:id])
    redirect_to @bookmark.url
  end

  def new    
    unless params[:bookmark]
      @bookmark = Bookmark.new
    else
      @bookmark = Bookmark.new(params[:bookmark])
    end
  end

  def create
    @bookmark = Bookmark.new(params[:bookmark])
    if @bookmark.save
      flash[:notice] = 'Bookmark was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @bookmark = Bookmark.find(params[:id])
  end

  def update
    @bookmark = Bookmark.find(params[:id])
    if @bookmark.update_attributes(params[:bookmark])
      flash[:notice] = 'Bookmark was successfully updated.'
      redirect_to :action => 'show', :id => @bookmark
    else
      render :action => 'edit'
    end
  end

  def destroy
    Bookmark.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
