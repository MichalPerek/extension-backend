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

  # Associations
  has_many :conversations, dependent: :destroy

  # Add any additional methods you need for your extension
  def plan
    'Pro Plan' # You can make this dynamic based on subscription
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
    points = case plan
    when 'Free Plan'
      10
    when 'Pro Plan'
      100
    when 'Enterprise Plan'
      1000
    else
      0
    end
    
    update!(initial_points: points, remaining_points: points)
  end

  def usage_stats
    {
      textsProcessed: conversations.count,
      monthlyLimit: initial_points,
      remainingPoints: remaining_points,
      pointsUsed: initial_points - remaining_points
    }
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
