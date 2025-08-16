class Api::UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: {
      user: {
        id: current_user.id,
        name: current_user.name,
        email: current_user.email,
        joinDate: current_user.join_date
      }
    }
  end

  def profile
    render json: {
      user: {
        name: current_user.name,
        email: current_user.email,
        joinDate: current_user.join_date
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
end
