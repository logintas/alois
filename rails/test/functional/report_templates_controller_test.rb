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
require 'report_templates_controller'

# Re-raise errors caught by the controller.
class ReportTemplatesController; def rescue_action(e) raise e end; end

class ReportTemplatesControllerTest < ActionController::TestCase
  fixtures :report_templates, :reports, :views, :filters
  
  def setup
    @controller = ReportTemplatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = ReportTemplate.find(:first).id
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

    assert_not_nil assigns(:report_templates)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:report_template)
    #    assert assigns(:report_template).valid?, "Report template is not valid: #{assigns(:report_template).errors.full_messages} (#{assigns(:report_template).inspect})"
  end

  def disabled_test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:report_template)
  end

  def test_create
    num_report_templates = ReportTemplate.count

    post :create, :report_template => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_report_templates + 1, ReportTemplate.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:report_template)
    assert assigns(:report_template).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      ReportTemplate.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      ReportTemplate.find(@first_id)
    }
  end


  def test_render_save
    c = Report.count
    get :show, :id => @first_id, :render => true, :time_span => "today", :table_name => "view_1", :commit => "Save as Report"

    assert_response :redirect
    assert_redirected_to :action => "show", :controller => "reports"

    assert_not_nil assigns(:report)
    assert assigns(:report).valid?
    assert_equal c + 1, Report.count
  end


  def test_render_preview_fake
    get :show, :id => @first_id, :render => true, :time_span => "today", :table_name => "view_1", :commit => "Preview with fake data"

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:report_template)
    assert assigns(:report_template).valid?
  end
  def test_render_preview_real
    get :show, :id => @first_id, :render => true, :time_span => "today", :table_name => "view_1", :commit => "Preview with real data"

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:report_template)
    assert assigns(:report_template).valid?
  end

end
