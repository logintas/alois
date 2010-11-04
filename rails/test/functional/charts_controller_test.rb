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
require 'charts_controller'

# Re-raise errors caught by the controller.
class ChartsController; def rescue_action(e) raise e end; end

class ChartsControllerTest < ActionController::TestCase
  fixtures :charts, :views

  def setup
    @controller = ChartsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @first_id = Chart.find(:first).id
  end
  
  def test_chart_image
    c = self.class.test_chart
    c.render(CHART_RENDER_OPTIONS)
    
    get :chart_image, 
      :chart_tmpdir_hash => CHART_QUERY.hash,
      :chart_yaml_hash =>  Object.yaml_hash(CHART_AFTER_RENDER_YAML)
    
    
    assert_response :success
    
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
    
    assert_not_nil assigns(:charts)
  end
  
  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:chart)
    assert assigns(:chart).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:chart)
  end

  def test_create
    num_charts = Chart.count

    post :create, :chart => {:column1 => "test"}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_charts + 1, Chart.count
  end

  def test_destroy
    assert_not_nil Chart.find(@first_id)

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Chart.find(@first_id)
    }
    
  end
  
end
