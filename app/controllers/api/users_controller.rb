class Api::UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: {
      user: {
        id: current_user.id,
        name: current_user.name,
        email: current_user.email,
        plan: current_user.plan,
        joinDate: current_user.join_date,
        usage: current_user.usage_stats
      }
    }
  end

  def profile
    render json: {
      user: {
        name: current_user.name,
        email: current_user.email,
        plan: current_user.plan,
        joinDate: current_user.join_date,
        usage: current_user.usage_stats
      }
    }
  end

  def usage
    render json: {
      usage: current_user.usage_stats
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
end
