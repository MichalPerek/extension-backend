require "test_helper"

class Api::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @token = "token_#{@user.id}_#{Time.current.to_i}"
  end

  test "should show user profile" do
    get profile_api_users_url, headers: { 'Authorization' => "Bearer #{@token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @user.name, json_response['user']['name']
    assert_equal @user.email, json_response['user']['email']
  end

  test "should show user by id" do
    get api_user_url(@user), headers: { 'Authorization' => "Bearer #{@token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @user.name, json_response['user']['name']
  end

  test "should not access without token" do
    get profile_api_users_url
    
    assert_response :unauthorized
  end
end
