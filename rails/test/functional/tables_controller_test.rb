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

class TablesControllerTest < ActionController::TestCase

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:tables)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_table
    assert_difference('Table.count') do
      post :create, :table => {}
    end

    assert_redirected_to :action => "list"
  end

  def test_should_show_table
    get :show, :id => Table.find(:first).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => Table.find(:first).id
    assert_response :success
  end

  def test_should_update_table
    put :update, :id => Table.find(:first).id, :table => { }
    assert_redirected_to 
  end

  def test_should_destroy_table
    assert_difference('Table.count', -1) do
      delete :destroy, :id => Table.find(:first).id
    end

    assert_redirected_to :action => "list"
  end
end
