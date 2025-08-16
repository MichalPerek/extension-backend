class Api::ConversationsController < ApplicationController
  before_action :authenticate_user!

  def create
    original_text = params[:original_text]
    instruction = params[:instruction]

    return render json: { error: 'Missing required parameters' }, status: :bad_request unless original_text && instruction

    # Check if user has points remaining
    unless current_user.can_make_step?
      return render json: { 
        error: 'No points remaining. Please upgrade your plan or wait for next month.' 
      }, status: :forbidden
    end

    # Deduct point first
    unless current_user.deduct_point!
      return render json: { error: 'Failed to deduct point' }, status: :internal_server_error
    end

    # Mock LLM response (replace with actual OpenAI call)
    llm_response = mock_llm_response(instruction, original_text)

    # Create conversation
    conversation = current_user.conversations.create!(
      original_text: original_text,
      conversation_steps: [{
        instruction: instruction,
        response: llm_response[:text],
        tokens_received: llm_response[:tokens],
        timestamp: Time.current.iso8601
      }],
      status: :active
    )

    render json: {
      success: true,
      response: llm_response[:text],
      conversation_id: conversation.id,
      remaining_points: current_user.remaining_points
    }
  end

  def add_step
    conversation = current_user.conversations.find(params[:id])
    instruction = params[:instruction]

    return render json: { error: 'Missing instruction' }, status: :bad_request unless instruction

    # Check if user has points remaining
    unless current_user.can_make_step?
      return render json: { 
        error: 'No points remaining. Please upgrade your plan or wait for next month.' 
      }, status: :forbidden
    end

    # Deduct point first
    unless current_user.deduct_point!
      return render json: { error: 'Failed to deduct point' }, status: :internal_server_error
    end

    # Mock LLM response (replace with actual OpenAI call)
    llm_response = mock_llm_response(instruction, conversation.original_text)

    # Add step to conversation
    conversation.add_step(
      instruction: instruction,
      response: llm_response[:text],
      tokens_received: llm_response[:tokens]
    )

    render json: {
      success: true,
      response: llm_response[:text],
      remaining_points: current_user.remaining_points
    }
  end

  def complete
    conversation = current_user.conversations.find(params[:id])
    final_text = params[:final_text]

    conversation.update!(
      status: :completed,
      final_text: final_text
    )

    render json: { success: true }
  end

  def discard
    conversation = current_user.conversations.find(params[:id])
    
    conversation.update!(status: :discarded)

    render json: { success: true }
  end

  def index
    conversations = current_user.conversations.order(created_at: :desc).limit(10)
    
    render json: {
      conversations: conversations.map do |conv|
        {
          id: conv.id,
          original_text: conv.original_text,
          status: conv.status,
          total_steps: conv.total_steps,
          total_tokens: conv.total_tokens_received,
          created_at: conv.created_at,
          current_response: conv.current_response
        }
      end
    }
  end

  private

  def authenticate_user!
    # For now, we'll use a simple token-based authentication
    # In production, you should use proper JWT tokens
    token = request.headers['Authorization']&.split(' ')&.last
    
    if token.blank?
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end

    # For development, we'll create a mock user
    # In production, you should decode the JWT token and find the user
    @current_user = User.first || create_mock_user
  end

  def current_user
    @current_user
  end

  def create_mock_user
    user = User.create!(
      name: 'John Doe',
      email: 'john@example.com',
      password: 'password123',
      provider: 'email',
      uid: 'john@example.com'
    )
    user.set_plan_points
    user
  end

  def mock_llm_response(instruction, original_text)
    # Mock response - replace with actual OpenAI API call
    {
      text: "Processed: '#{original_text}' with instruction: '#{instruction}'",
      tokens: rand(50..200)
    }
  end
end
