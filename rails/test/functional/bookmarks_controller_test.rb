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

require File.dirname(__FILE__) + '/../test_helper'
require 'bookmarks_controller'

# Re-raise errors caught by the controller.
class BookmarksController; def rescue_action(e) raise e end; end

class BookmarksControllerTest < ActionController::TestCase
  fixtures :bookmarks

  def setup
    @controller = BookmarksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = Bookmark.find(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:bookmarks)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:bookmark)
    assert assigns(:bookmark).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:bookmark)
  end

  def test_create
    num_bookmarks = Bookmark.count

    post :create, :bookmark => {:title => "Test", :controller => "SurveyController", :action => "list"}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_bookmarks + 1, Bookmark.count
  end

  def test_go
    get :go, :id => @first_id

    assert_response :redirect
    assert_redirected_to({:action => 'list', :controller => "AlarmsController"})
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:bookmark)
    assert assigns(:bookmark).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Bookmark.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Bookmark.find(@first_id)
    }
  end
end
