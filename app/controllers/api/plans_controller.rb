class Api::PlansController < ApplicationController
  before_action :authenticate_user!

  def index
    plans = Plan.active.ordered
    
    render json: {
      plans: plans.map do |plan|
        {
          id: plan.id,
          name: plan.name,
          points: plan.points,
          description: plan.description,
          active: plan.active,
          user_count: plan.users.count
        }
      end
    }
  end

  def show
    plan = Plan.find(params[:id])
    
    render json: {
      plan: {
        id: plan.id,
        name: plan.name,
        points: plan.points,
        description: plan.description,
        active: plan.active,
        user_count: plan.users.count,
        created_at: plan.created_at,
        updated_at: plan.updated_at
      }
    }
  end

  def create
    plan = Plan.new(plan_params)

    if plan.save
      render json: {
        success: true,
        plan: {
          id: plan.id,
          name: plan.name,
          points: plan.points,
          description: plan.description,
          active: plan.active
        }
      }, status: :created
    else
      render json: {
        success: false,
        error: plan.errors.full_messages.join(', ')
      }, status: :unprocessable_entity
    end
  end

  def update
    plan = Plan.find(params[:id])

    if plan.update(plan_params)
      render json: {
        success: true,
        plan: {
          id: plan.id,
          name: plan.name,
          points: plan.points,
          description: plan.description,
          active: plan.active
        }
      }
    else
      render json: {
        success: false,
        error: plan.errors.full_messages.join(', ')
      }, status: :unprocessable_entity
    end
  end

  def destroy
    plan = Plan.find(params[:id])
    
    if plan.users.exists?
      render json: {
        success: false,
        error: "Cannot delete plan that has users assigned to it"
      }, status: :unprocessable_entity
      return
    end

    if plan.destroy
      render json: { success: true }
    else
      render json: {
        success: false,
        error: plan.errors.full_messages.join(', ')
      }, status: :unprocessable_entity
    end
  end

  def assign_to_user
    user = User.find(params[:user_id])
    plan = Plan.find(params[:id])

    if user.assign_plan(plan.name)
      render json: {
        success: true,
        message: "Plan #{plan.name} assigned to user #{user.name}",
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          plan: user.plan_name,
          usage: user.usage_stats
        }
      }
    else
      render json: {
        success: false,
        error: "Failed to assign plan to user"
      }, status: :unprocessable_entity
    end
  end

  private

  def plan_params
    params.require(:plan).permit(:name, :points, :description, :active)
  end

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
      name: 'Admin User',
      email: 'admin@example.com',
      provider: 'email',
      uid: 'admin@example.com'
    )
    user.set_plan_points
    user
  end
end
