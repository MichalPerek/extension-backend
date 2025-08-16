class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  has_many :conversations, dependent: :destroy

  def join_date
    created_at.strftime('%B %Y')
  end
end
