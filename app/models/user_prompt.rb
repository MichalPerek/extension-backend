class UserPrompt < ApplicationRecord
  belongs_to :account

  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true, length: { maximum: 10000 }

  scope :by_account, ->(account_id) { where(account_id: account_id) }
  scope :recent, -> { order(created_at: :desc) }
end
