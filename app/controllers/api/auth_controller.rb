class Api::AuthController < ApplicationController
  def login
    email = params[:email]
    password = params[:password]

    user = User.find_by(email: email)

    if user&.valid_password?(password)
      render json: {
        success: true,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          plan: user.plan_name,
          joinDate: user.join_date,
          usage: user.usage_stats
        },
        token: generate_token(user)
      }
    else
      render json: { 
        success: false, 
        error: 'Invalid email or password' 
      }, status: :unauthorized
    end
  end

  def signup
    name = params[:name]
    email = params[:email]
    # password = params[:password] # Not using password for now

    if User.exists?(email: email)
      render json: { 
        success: false, 
        error: 'Email already exists' 
      }, status: :unprocessable_entity
      return
    end

    user = User.new(
      name: name,
      email: email,
      # password: password, # Not using password for now
      provider: 'email',
      uid: email
    )

    if user.save
      # Set initial points based on plan
      user.set_plan_points
      
      render json: {
        success: true,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          plan: user.plan_name,
          joinDate: user.join_date,
          usage: user.usage_stats
        },
        token: generate_token(user)
      }
    else
      render json: { 
        success: false, 
        error: user.errors.full_messages.join(', ') 
      }, status: :unprocessable_entity
    end
  end

  private

  def generate_token(user)
    # For development, we'll use a simple token
    # In production, you should use JWT tokens
    "token_#{user.id}_#{Time.current.to_i}"
  end
end
