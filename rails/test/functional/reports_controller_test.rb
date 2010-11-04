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
require 'reports_controller'

# Re-raise errors caught by the controller.
class ReportsController; def rescue_action(e) raise e end; end

class ReportsControllerTest < ActionController::TestCase
  fixtures :reports, :report_templates, :views, :filters

  def setup
    @controller = ReportsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @first_id = Report.find(:first).id

    unless @report
      @report_template = ReportTemplate.find(1)
      @report_template.delete_cache
      @options = {
	:url => "someurl?",
	:datasource => View.find(1) }
      @report = Report.generate(@report_template,"test", @options)
    end
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

    assert_not_nil assigns(:reports)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:report)
    assert assigns(:report).valid?
  end


  def disabled_test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:report)
  end

  def disabled_test_create
    num_reports = Report.count

    post :create, :report => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_reports + 1, Report.count
  end

  def disabled_test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:report)
    assert assigns(:report).valid?
  end

  def disabled_test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Report.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Report.find(@first_id)
    }
  end

  def test_send_to_email
    get :send_to_email, :id => @report
    assert_response :success
    assert_template 'send_to_email'    
  end

  def test_email_preview_simple
    get :email_preview, :id => @report, :type => "simple"
    assert_response :success
  end

  def test_email_preview_normal
    get :email_preview, :id => @report, :type => "simple"
    assert_response :success
  end
end
