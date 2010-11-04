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

class IpRangesControllerTest < ActionController::TestCase
  fixtures :ip_ranges

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:ip_ranges)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_ip_range
    assert_difference('IpRange.count') do
      post :create, :ip_range => {:name => "xxx", :from_ip => "192.168.1.1" }
    end

    assert_redirected_to ip_range_path(assigns(:ip_range))
  end

  def test_should_show_ip_range
    get :show, :id => IpRange.find(:first)
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => IpRange.find(:first)
    assert_response :success
  end

  def test_should_update_ip_range
    put :update, :id => IpRange.find(:first), :ip_range => { }
    assert_redirected_to ip_range_path(assigns(:ip_range))
  end

  def test_should_destroy_ip_range
    assert_difference('IpRange.count', -1) do
      delete :destroy, :id => IpRange.find(:first)
    end

    assert_redirected_to ip_ranges_path
  end
end
