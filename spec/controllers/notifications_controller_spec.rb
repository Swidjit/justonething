require 'spec_helper'

describe NotificationsController do
  describe 'GET index' do
    render_views

    it 'should be successful when logged in' do
      rec = Factory(:recommendation)
      sign_in rec.item.user
      get :index, :user_id => rec.item.user.id
      response.should be_success
      response.should render_template('index')
      response.should render_template('layouts/application')
      response.body.should =~ Regexp.new(rec.item.title)
    end

    it 'should redirect when not logged in' do
      get :index
      response.should be_redirect
    end
  end
end
