require "test_helper"

class Api::AuthControllerTest < ActionDispatch::IntegrationTest
  test "should create user on signup" do
    assert_difference('User.count') do
      post api_auth_signup_url, params: {
        name: "Test User",
        email: "test@example.com",
        password: "password123"
      }
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response['success']
    assert_equal "Test User", json_response['user']['name']
  end

  test "should login with valid credentials" do
    user = users(:one)
    
    post api_auth_login_url, params: {
      email: user.email,
      password: "password123"
    }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response['success']
    assert_equal user.name, json_response['user']['name']
  end

  test "should not login with invalid credentials" do
    post api_auth_login_url, params: {
      email: "wrong@example.com",
      password: "wrongpassword"
    }

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_not json_response['success']
  end
end
