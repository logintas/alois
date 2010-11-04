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
require 'filters_controller'

# Re-raise errors caught by the controller.
class FiltersController; def rescue_action(e) raise e end; end

class FiltersControllerTest < ActionController::TestCase
  fixtures :filters

  def setup
    @controller = FiltersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = Filter.find(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
    assert_tidy_html
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:filters)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:current_filter)
    assert assigns(:current_filter).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:current_filter)
  end

  def test_create
    num_filters = Filter.count

    post :create, :current_filter => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_filters + 1, Filter.count
  end

  def test_edit_and_update
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:current_filter)
    assert assigns(:current_filter).valid?

    assert assigns(:state_id)
    post :add_condition, :operator => "LIKE", :column => "test", :value => "test_value", :state_id => assigns(:state_id)       
    post :update, :id => @first_id, :state_id => assigns(:state_id)
    
    f = Filter.find(@first_id)
    assert f
    assert f.conditions
    assert 2, f.conditions.length
  end

  def test_destroy
    assert_not_nil Filter.find(@first_id)

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Filter.find(@first_id)
    }
  end
end
