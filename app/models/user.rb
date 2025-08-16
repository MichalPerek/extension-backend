class User < ApplicationRecord
  # Temporarily comment out Devise for testing
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  # include DeviseTokenAuth::Concerns::User

  # Add additional fields for the Chrome extension
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :initial_points, numericality: { greater_than_or_equal_to: 0 }
  validates :remaining_points, numericality: { greater_than_or_equal_to: 0 }
  validates :role, presence: true, inclusion: { in: %w[admin standard] }

  # Associations
  has_many :conversations, dependent: :destroy
  belongs_to :plan, optional: true

  # Add any additional methods you need for your extension
  def plan_name
    plan&.name || 'Free Plan'
  end

  # Point management methods
  def can_make_step?
    remaining_points > 0
  end

  def deduct_point!
    return false if remaining_points <= 0
    
    update!(remaining_points: remaining_points - 1)
    true
  end

  def add_points(points)
    update!(remaining_points: remaining_points + points)
  end

  def reset_points_to_initial
    update!(remaining_points: initial_points)
  end

  # Plan-based initial points
  def set_plan_points
    user_plan = plan || Plan.default_plan
    return unless user_plan
    
    points = user_plan.points
    update!(initial_points: points, remaining_points: points)
  end

  def assign_plan(plan_name)
    new_plan = Plan.find_by_name(plan_name)
    return false unless new_plan
    
    update!(plan: new_plan)
    set_plan_points
    true
  end

  def usage_stats
    {
      textsProcessed: conversations.count,
      monthlyLimit: initial_points,
      remainingPoints: remaining_points,
      pointsUsed: initial_points - remaining_points,
      planName: plan_name
    }
  end

  # Role-based methods
  def admin?
    role == 'admin'
  end

  def standard?
    role == 'standard'
  end

  def can_manage_users?
    admin?
  end

  def can_manage_plans?
    admin?
  end

  def can_view_all_conversations?
    admin?
  end

  def role_permissions
    case role
    when 'admin'
      {
        canManageUsers: true,
        canManagePlans: true,
        canViewAllConversations: true,
        canDeleteContent: true,
        canModifySettings: true
      }
    when 'standard'
      {
        canManageUsers: false,
        canManagePlans: false,
        canViewAllConversations: false,
        canDeleteContent: false,
        canModifySettings: false
      }
    else
      {}
    end
  end

  def join_date
    created_at.strftime('%B %Y')
  end

  # Simple password validation for testing
  def valid_password?(password)
    # For testing purposes, accept any password
    true
  end
end
