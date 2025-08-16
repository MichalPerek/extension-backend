class Conversation < ApplicationRecord
  belongs_to :user

  validates :original_text, presence: true

  def total_steps
    1
  end
end
