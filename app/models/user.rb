class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  include DeviseTokenAuth::Concerns::User

  # Add additional fields for the Chrome extension
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  # Add any additional methods you need for your extension
  def plan
    'Pro Plan' # You can make this dynamic based on subscription
  end

  def usage_stats
    {
      textsProcessed: 247, # This should come from actual usage data
      monthlyLimit: 1000
    }
  end

  def join_date
    created_at.strftime('%B %Y')
  end
end
