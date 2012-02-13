require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "can get index" do
    get :index
    assert_response :success
  end
end
