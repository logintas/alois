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
require 'alarms_controller'

# Re-raise errors caught by the controller.
class AlarmsController; def rescue_action(e) raise e end; end

class AlarmsControllerTest < ActionController::TestCase
  fixtures :alarms

  def setup
    @controller = AlarmsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = Alarm.find(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'status'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'status'

    assert_not_nil assigns(:alarms)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:alarm)
    assert assigns(:alarm).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:alarm)
  end

  def test_create
    num_alarms = Alarm.count

    post :create, :alarm => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_alarms + 1, Alarm.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:alarm)
    assert assigns(:alarm).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Alarm.find(@first_id)
    }
    assert_raise(RuntimeError) {
      post :destroy, :id => @first_id
    }
#    assert_response :redirect
#    assert_redirected_to :action => 'list'

    assert_nothing_raised {
      Alarm.find(@first_id)
    }
  end
end
