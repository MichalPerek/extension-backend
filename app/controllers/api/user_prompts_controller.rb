class Api::UserPromptsController < ApplicationController
  before_action :require_authentication
  before_action :set_user_prompt, only: [:show, :update, :destroy]

  # GET /api/user_prompts
  def index
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
end
