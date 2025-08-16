class Conversation < ApplicationRecord
  belongs_to :user

  validates :original_text, presence: true
  validates :conversation_steps, presence: true

  enum status: { active: 0, completed: 1, discarded: 2 }

  # For analytics only
  def total_steps
    conversation_steps.length
  end

  def total_tokens_received
    conversation_steps.sum { |step| step['tokens_received'] || 0 }
  end

  def current_response
    conversation_steps.last&.dig('response')
  end

  def iterations_count
    [conversation_steps.length - 1, 0].max
  end

  def all_instructions
    conversation_steps.map { |step| step['instruction'] }
  end

  def add_step(instruction:, response:, tokens_received:)
    new_step = {
      instruction: instruction,
      response: response,
      tokens_received: tokens_received,
      timestamp: Time.current.iso8601
    }
    
    update!(conversation_steps: conversation_steps + [new_step])
  end
end
