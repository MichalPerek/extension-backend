require "test_helper"

class Api::ConversationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @token = "token_#{@user.id}_#{Time.current.to_i}"
  end

  test "should create conversation" do
    assert_difference('Conversation.count') do
      post api_conversations_url, params: {
        original_text: "Test conversation text"
      }, headers: { 'Authorization' => "Bearer #{@token}" }
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response['success']
    assert json_response['conversation_id']
  end

  test "should list conversations" do
    get api_conversations_url, headers: { 'Authorization' => "Bearer #{@token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response['conversations']
  end

  test "should show conversation" do
    conversation = conversations(:one)
    get api_conversation_url(conversation), headers: { 'Authorization' => "Bearer #{@token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal conversation.original_text, json_response['conversation']['original_text']
  end

  test "should not create conversation without text" do
    post api_conversations_url, params: {}, headers: { 'Authorization' => "Bearer #{@token}" }
    
    assert_response :bad_request
  end

  test "should not access without token" do
    get api_conversations_url
    
    assert_response :unauthorized
  end
end
