class Api::ConversationsController < ApplicationController
  before_action :require_authentication
  before_action :set_conversation, only: [:show, :update, :destroy]

  def index
    conversations = current_account.conversations.recent.limit(50)
    
    render json: {
      conversations: conversations.map(&:to_summary_hash)
    }
  end

  def show
    render json: {
      conversation: @conversation.to_api_hash
    }
  end

  def update
    case params[:action_type]
    when 'complete'
      @conversation.update!(status: 'completed')
    when 'archive'
      @conversation.update!(status: 'archived')
    when 'reactivate'
      @conversation.update!(status: 'active')
    else
      return render json: { error: 'Invalid action_type' }, status: :bad_request
    end

    render json: {
      conversation: @conversation.to_summary_hash,
      message: "Conversation #{params[:action_type]}d successfully"
    }
  end

  def destroy
    @conversation.destroy!
    render json: { message: 'Conversation deleted successfully' }
  end

  def by_session
    session_id = params[:session_id]
    
    if session_id.blank?
      return render json: { error: 'Session ID is required' }, status: :bad_request
    end

    conversations = current_account.conversations.by_session(session_id).recent
    
    render json: {
      conversations: conversations.map(&:to_api_hash),
      session_id: session_id
    }
  end

  def stats
    conversations = current_account.conversations
    
    stats = {
      total_conversations: conversations.count,
      active_conversations: conversations.active.count,
      completed_conversations: conversations.completed.count,
      archived_conversations: conversations.archived.count,
      total_iterations: conversations.sum(:iteration_count),
      total_processing_time: conversations.sum(&:total_processing_time),
      total_tokens_used: conversations.sum(&:total_tokens_used)
    }

    render json: { stats: stats }
  end

  private

  def current_account
    rodauth.rails_account
  end

  def set_conversation
    @conversation = current_account.conversations.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Conversation not found' }, status: :not_found
  end
end
