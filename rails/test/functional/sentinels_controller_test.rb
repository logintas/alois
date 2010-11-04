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
require 'sentinels_controller'

# Re-raise errors caught by the controller.
class SentinelsController; def rescue_action(e) raise e end; end

class SentinelsControllerTest < ActionController::TestCase
  fixtures :views,:sentinels

  def setup
    @controller = SentinelsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = Sentinel.find(:first).id
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

    assert_not_nil assigns(:sentinels)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:sentinel)
    assert assigns(:sentinel).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:sentinel)
  end

  def test_create
    num_sentinels = Sentinel.count

    post :create, :sentinel => {
      :name => "New Sentinel",
      :view_id => View.find(:first).id,
      :threshold => 0,
      :cron_interval => "0 0 0 0 0"
    }

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_sentinels + 1, Sentinel.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:sentinel)
    assert assigns(:sentinel).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_not_nil Sentinel.find(@first_id)

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Sentinel.find(@first_id)
    }
  end

  def test_load_yaml
    post :new, :current_object_zip =>
      "RY5BbsMwDATvfoWau9H06nN/kAcItL1wWEiiQTFO/PvQao2CF3KHu2Tf9+FD\n" +
      "H+P+KeMPJhtuKMYFKXRkpjw+DHUIXQiFMoZwk4xQ/3ZcNc6ISmVxtqMadKbd\n" +
      "dV+ZYyZOQ7hcLy4cfTRpUXZX1Luk+YSTSolc3L2RO65nOaJEmmPChtS8NBlL\n" +
      "aS0f/q/DP6NOyusv+fbh/EBq5XxewcsPFEpxVVmUcgvZGM/4n6RYRS0a8prI\n" +
      "0Ej3Bn4xW/o="
    
    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:sentinel)
    assert "Some sentinel", assigns(:sentinel).name
  end
end
