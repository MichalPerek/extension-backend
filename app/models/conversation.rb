class Conversation < ApplicationRecord
  belongs_to :account

  # Enums (must be defined before validations that reference them)
  enum :status, { active: 0, completed: 1, archived: 2 }

  # Validations
  validates :original_text, presence: true, length: { maximum: -> { AppConfig.current.max_original_text_length } }
  validates :status, inclusion: { in: statuses.keys }
  validate :iterations_limit
  
  # Callbacks
  before_validation :ensure_iterations_array

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :for_account, ->(account) { where(account: account) }
  scope :by_session, ->(session_id) { where(session_id: session_id) }

  # Instance methods
  def add_iteration(instruction:, result_text:, language:, task_summary:, model:, provider:, model_name:, usage:, processing_time:)
    # Validate input lengths
    max_instruction = AppConfig.current.max_instruction_length
    max_result = AppConfig.current.max_result_text_length
    max_iterations = account.max_iterations_per_conversation
    
    raise ArgumentError, "Instruction too long (max #{max_instruction} chars)" if instruction.to_s.length > max_instruction
    raise ArgumentError, "Result text too long (max #{max_result} chars)" if result_text.to_s.length > max_result
    
    # Check iteration limit
    if iteration_count >= max_iterations
      raise ArgumentError, "Maximum #{max_iterations} iterations per conversation exceeded"
    end

    iteration = {
      id: SecureRandom.uuid,
      instruction: instruction.to_s.strip,
      result_text: result_text.to_s.strip,
      language: language.to_s.strip,
      task_summary: task_summary.to_s.strip,
      model: model.to_s.strip,
      provider: provider.to_s.strip,
      model_name: model_name.to_s.strip,
      usage: usage || {},
      processing_time: processing_time.to_f,
      created_at: Time.current.iso8601
    }
    
    self.iterations = (safe_iterations || []) + [iteration]
    save!
    
    iteration
  end

  def latest_iteration
    safe_iterations&.last
  rescue JSON::ParserError, TypeError => e
    Rails.logger.error "Failed to parse iterations for conversation #{id}: #{e.message}"
    nil
  end

  def latest_result
    latest_iteration&.dig('result_text')
  end

  def iteration_count
    safe_iterations&.size || 0
  end

  def can_add_iteration?
    iteration_count < account.max_iterations_per_conversation
  end

  def iterations_remaining
    account.max_iterations_per_conversation - iteration_count
  end

  def first_instruction
    safe_iterations&.first&.dig('instruction')
  end

  def all_instructions
    safe_iterations&.map { |iter| iter['instruction'] } || []
  end

  def total_processing_time
    safe_iterations&.sum { |iter| iter['processing_time'] || 0 } || 0
  end

  def total_tokens_used
    safe_iterations&.sum { |iter| iter.dig('usage', 'totalTokens') || 0 } || 0
  end

  # Generate a session ID for grouping related conversations
  def self.generate_session_id
    "session_#{SecureRandom.hex(8)}_#{Time.current.to_i}"
  end

  # Find or create a conversation for continuing iterations
  def self.find_or_create_for_iteration(account:, original_text:, session_id: nil)
    session_id ||= generate_session_id
    
    # Try to find an existing active conversation with the same original text and session
    existing = where(account: account, original_text: original_text, session_id: session_id, status: 'active').first
    
    return existing if existing
    
    # Create a new conversation
    create!(
      account: account,
      original_text: original_text,
      session_id: session_id,
      status: 'active'
    )
  end

  def to_api_hash
    {
      id: id,
      original_text: original_text,
      latest_result: latest_result,
      iteration_count: iteration_count,
      iterations_remaining: iterations_remaining,
      can_add_iteration: can_add_iteration?,
      first_instruction: first_instruction,
      all_instructions: all_instructions,
      status: status,
      session_id: session_id,
      total_processing_time: total_processing_time,
      total_tokens_used: total_tokens_used,
      created_at: created_at,
      updated_at: updated_at,
      iterations: safe_iterations
    }
  end

  def to_summary_hash
    {
      id: id,
      original_text: original_text.truncate(100),
      latest_result: latest_result&.truncate(100),
      iteration_count: iteration_count,
      iterations_remaining: iterations_remaining,
      can_add_iteration: can_add_iteration?,
      first_instruction: first_instruction,
      status: status,
      session_id: session_id,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  private

  def ensure_iterations_array
    self.iterations = [] if iterations.nil?
  end

  def safe_iterations
    return [] if iterations.nil?
    return iterations if iterations.is_a?(Array)
    
    # Handle case where iterations might be corrupted
    JSON.parse(iterations.to_json)
  rescue JSON::ParserError, TypeError => e
    Rails.logger.error "Failed to parse iterations for conversation #{id}: #{e.message}"
    []
  end

  def iterations_limit
    return unless iterations.present?
    
    max_allowed = account.max_iterations_per_conversation
    if iteration_count > max_allowed
      errors.add(:iterations, "cannot exceed #{max_allowed} iterations per conversation for your license type")
    end
  end
end
