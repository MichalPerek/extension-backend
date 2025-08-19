class AppConfig < ApplicationRecord
  validates_uniqueness_of :id, message: "Only one configuration record allowed"
  
  # Validations
  validates :max_iterations, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 50 }
  validates :max_original_text_length, presence: true, numericality: { greater_than: 100, less_than_or_equal_to: 100_000 }
  validates :max_result_text_length, presence: true, numericality: { greater_than: 100, less_than_or_equal_to: 500_000 }
  validates :max_instruction_length, presence: true, numericality: { greater_than: 10, less_than_or_equal_to: 10_000 }
  validates :global_monthly_token_limit, presence: true, numericality: { greater_than: 1000 }
  validates :estimated_tokens_per_call, presence: true, numericality: { greater_than: 10, less_than_or_equal_to: 10000 }
  validates :token_price_usd, presence: true, numericality: { greater_than: 0 }

  # Singleton pattern
  def self.current
    Rails.cache.fetch('app_config_current', expires_in: 1.hour) do
      config = first_or_create! do |c|
        c.global_month_start = Date.current.beginning_of_month
      end
      config.reset_global_counter_if_needed
      config
    end
  end

  # Check if a call can be made (both global and user limits)
  def self.can_make_call?(account)
    config = current
    
    # Check if user's license is active
    return { allowed: false, reason: 'license_expired', type: 'user' } if account.license_expired?
    
    # Check global app limit first
    return { allowed: false, reason: 'global_limit_exceeded', type: 'global' } if config.global_limit_exceeded?
    
    # Check if global app has enough estimated tokens
    estimated_tokens = config.estimated_tokens_per_call
    return { allowed: false, reason: 'global_insufficient_tokens', type: 'global', needed: estimated_tokens, available: config.global_tokens_remaining } if config.global_tokens_remaining < estimated_tokens
    
    # Check user limit
    return { allowed: false, reason: 'user_limit_exceeded', type: 'user' } if account.user_limit_exceeded?
    
    # Check if user has enough estimated tokens
    return { allowed: false, reason: 'user_insufficient_tokens', type: 'user', needed: estimated_tokens, available: account.user_tokens_remaining } if account.user_tokens_remaining < estimated_tokens
    
    # Check daily conversation limit
    return { allowed: false, reason: 'daily_conversation_limit', type: 'user', used: account.conversations_today, limit: account.max_conversations_per_day } unless account.can_create_conversation?
    
    { allowed: true }
  end

  # Global token tracking
  def add_global_token_usage(tokens_used)
    reset_global_counter_if_needed
    
    self.class.transaction do
      increment!(:global_current_month_tokens_used, tokens_used)
      clear_cache
    end
    
    Rails.logger.info "Added #{tokens_used} global tokens. Total this month: #{global_current_month_tokens_used}/#{global_monthly_token_limit}"
  end

  def global_tokens_remaining
    [global_monthly_token_limit - global_current_month_tokens_used, 0].max
  end

  def global_limit_exceeded?
    global_current_month_tokens_used >= global_monthly_token_limit
  end

  def global_usage_percentage
    return 0 if global_monthly_token_limit == 0
    ((global_current_month_tokens_used.to_f / global_monthly_token_limit) * 100).round(2)
  end

  def global_monthly_cost
    (global_current_month_tokens_used * token_price_usd).round(4)
  end

  def reset_global_counter_if_needed
    current_month = Date.current.beginning_of_month
    
    if global_month_start != current_month
      update_columns(
        global_current_month_tokens_used: 0,
        global_month_start: current_month
      )
      clear_cache
      Rails.logger.info "Reset global monthly token counter for #{current_month}"
    end
  end

  # Console helper methods
  def self.update_limits(max_iterations: nil, max_original_text_length: nil, max_result_text_length: nil, max_instruction_length: nil)
    config = current
    config.update!(
      max_iterations: max_iterations || config.max_iterations,
      max_original_text_length: max_original_text_length || config.max_original_text_length,
      max_result_text_length: max_result_text_length || config.max_result_text_length,
      max_instruction_length: max_instruction_length || config.max_instruction_length
    )
    puts "✅ Conversation limits updated"
    config
  end

  def self.update_global_tokens(monthly_limit: nil, price_per_token: nil, estimated_per_call: nil)
    config = current
    config.update!(
      global_monthly_token_limit: monthly_limit || config.global_monthly_token_limit,
      token_price_usd: price_per_token || config.token_price_usd,
      estimated_tokens_per_call: estimated_per_call || config.estimated_tokens_per_call
    )
    puts "✅ Global token configuration updated"
    config
  end

  def self.show
    config = current
    puts "\n📋 App Configuration:"
    puts "=" * 60
    puts "Conversation Limits:"
    puts "  Max iterations: #{config.max_iterations}"
    puts "  Max original text: #{config.max_original_text_length} chars"
    puts "  Max result text: #{config.max_result_text_length} chars"
    puts "  Max instruction: #{config.max_instruction_length} chars"
    puts "\nGlobal App Token Usage (#{config.global_month_start.strftime('%B %Y')}):"
    puts "  Monthly limit: #{config.global_monthly_token_limit.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  Used this month: #{config.global_current_month_tokens_used.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  Remaining: #{config.global_tokens_remaining.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  Usage: #{config.global_usage_percentage}%"
    puts "  Monthly cost: $#{config.global_monthly_cost}"
    puts "  Limit exceeded: #{config.global_limit_exceeded? ? '❌ YES' : '✅ NO'}"
    puts "\nToken Configuration:"
    puts "  Price per token: $#{config.token_price_usd}"
    puts "  Estimated tokens per call: #{config.estimated_tokens_per_call}"
    puts "\nLicense Types:"
    LicenseType.active.ordered.each do |license|
      puts "  #{license.display_name}: #{license.monthly_token_limit} tokens/month ($#{license.price_per_month}/month)"
    end
    puts "=" * 60
    config
  end

  def self.reset_global_usage
    config = current
    config.update!(
      global_current_month_tokens_used: 0,
      global_month_start: Date.current.beginning_of_month
    )
    puts "✅ Global monthly token usage reset"
    config
  end

  after_update :clear_cache
  after_create :clear_cache

  private

  def clear_cache
    Rails.cache.delete('app_config_current')
  end
end
