require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @conversation = @user.conversations.build(
      original_text: "Test conversation",
      final_text: "Processed test conversation"
    )
  end

  test "should be valid" do
    assert @conversation.valid?
  end

  test "original_text should be present" do
    @conversation.original_text = nil
    assert_not @conversation.valid?
  end

  test "should belong to user" do
    @conversation.user = nil
    assert_not @conversation.valid?
  end

  test "total_steps should return 1" do
    assert_equal 1, @conversation.total_steps
  end
end
