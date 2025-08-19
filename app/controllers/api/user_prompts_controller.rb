class Api::UserPromptsController < ApplicationController
  before_action :require_authentication
  before_action :set_user_prompt, only: [:show, :update, :destroy]
  before_action :check_rate_limit, only: [:index]

  # GET /api/user_prompts
  def index
    # Add comprehensive logging to debug infinite queries
    account_id = current_account.id
    timestamp = Time.current
    user_agent = request.user_agent
    ip_address = request.remote_ip
    
    Rails.logger.info "UserPrompts#index called for account #{account_id} at #{timestamp} from #{ip_address} with UA: #{user_agent}"
    
    # Check if this is a repeated call from the same account
    cache_key = "user_prompts_rate_limit:#{account_id}"
    call_count = Rails.cache.read(cache_key) || 0
    
    if call_count > 20 # More than 20 calls in the rate limit window
      Rails.logger.warn "Rate limit exceeded for account #{account_id}: #{call_count} calls"
      render json: { error: 'Rate limit exceeded. Please wait before making more requests.' }, status: :too_many_requests
      return
    end
    
    # Increment call count
    Rails.cache.write(cache_key, call_count + 1, expires_in: 1.minute)
    
    @user_prompts = current_account.user_prompts.recent
    render json: {
      prompts: @user_prompts.map do |prompt|
        {
          id: prompt.id,
          title: prompt.title,
          content: prompt.content,
          created_at: prompt.created_at,
          updated_at: prompt.updated_at
        }
      end
    }
  end

  # GET /api/user_prompts/:id
  def show
    render json: {
      prompt: {
        id: @user_prompt.id,
        title: @user_prompt.title,
        content: @user_prompt.content,
        created_at: @user_prompt.created_at,
        updated_at: @user_prompt.updated_at
      }
    }
  end

  # POST /api/user_prompts
  def create
    @user_prompt = current_account.user_prompts.build(user_prompt_params)

    if @user_prompt.save
      render json: {
        prompt: {
          id: @user_prompt.id,
          title: @user_prompt.title,
          content: @user_prompt.content,
          created_at: @user_prompt.created_at,
          updated_at: @user_prompt.updated_at
        }
      }, status: :created
    else
      render json: {
        errors: @user_prompt.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/user_prompts/:id
  def update
    if @user_prompt.update(user_prompt_params)
      render json: {
        prompt: {
          id: @user_prompt.id,
          title: @user_prompt.title,
          content: @user_prompt.content,
          created_at: @user_prompt.created_at,
          updated_at: @user_prompt.updated_at
        }
      }
    else
      render json: {
        errors: @user_prompt.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/user_prompts/:id
  def destroy
    @user_prompt.destroy
    head :no_content
  end

  private

  def set_user_prompt
    @user_prompt = current_account.user_prompts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Prompt not found' }, status: :not_found
  end

  def user_prompt_params
    params.require(:user_prompt).permit(:title, :content)
  end

  def check_rate_limit
    # Additional rate limiting check
    account_id = current_account.id
    cache_key = "user_prompts_global_rate_limit:#{account_id}"
    
    # Check global rate limit (max 100 calls per hour)
    global_count = Rails.cache.read(cache_key) || 0
    if global_count > 100
      Rails.logger.error "Global rate limit exceeded for account #{account_id}: #{global_count} calls per hour"
      render json: { error: 'Global rate limit exceeded. Please contact support.' }, status: :too_many_requests
      return
    end
    
    # Increment global counter
    Rails.cache.write(cache_key, global_count + 1, expires_in: 1.hour)
  end
end
