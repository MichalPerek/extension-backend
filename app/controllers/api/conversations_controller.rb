class Api::ConversationsController < ApplicationController
  before_action :authenticate_user!

  def create
    original_text = params[:original_text]

    return render json: { error: 'Missing required parameters' }, status: :bad_request unless original_text

    # Mock LLM response (replace with actual OpenAI call)
    llm_response = mock_llm_response(original_text)

    # Create conversation
    conversation = current_user.conversations.create!(
      original_text: original_text,
      final_text: llm_response[:text]
    )

    render json: {
      success: true,
      response: llm_response[:text],
      conversation_id: conversation.id
    }
  end

  def index
    conversations = current_user.conversations.order(created_at: :desc).limit(10)
    
    render json: {
      conversations: conversations.map do |conv|
        {
          id: conv.id,
          original_text: conv.original_text,
          final_text: conv.final_text,
          created_at: conv.created_at
        }
      end
    }
  end

  def show
    conversation = current_user.conversations.find(params[:id])
    
    render json: {
      conversation: {
        id: conversation.id,
        original_text: conversation.original_text,
        final_text: conversation.final_text,
        created_at: conversation.created_at
      }
    }
  end

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    
    if token.blank?
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end

    # Simple token parsing for development
    # In production, use proper JWT tokens
    user_id = token.split('_')[1]
    @current_user = User.find_by(id: user_id)
    
    unless @current_user
      render json: { error: 'Invalid token' }, status: :unauthorized
      return
    end
  end

  def current_user
    @current_user
  end

  def mock_llm_response(original_text)
    # Mock response - replace with actual OpenAI API call
    {
      text: "Processed: '#{original_text}' - This is a mock response. Replace with actual OpenAI API call."
    }
  end
end
