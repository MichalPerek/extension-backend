require "test_helper"

class Api::AuthControllerTest < ActionDispatch::IntegrationTest
  test "should get login" do
    get api_auth_login_url
    assert_response :success
  end

  test "should get signup" do
    get api_auth_signup_url
    assert_response :success
  end
end
