require File.dirname(__FILE__) + '/../spec_helper'

describe HomeController do
  describe "GET index" do
    it "should be success" do
      get :index
      response.should be_success
    end
  end
end