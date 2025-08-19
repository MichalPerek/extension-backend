class Account < ApplicationRecord
  include Rodauth::Rails.model
  
  belongs_to :license_type, optional: true
  has_many :user_prompts, dependent: :destroy
  has_many :conversations, dependent: :destroy

  # Set default license after creation
  after_create :assign_default_license

  def effective_license_type
    license_type || LicenseType.find_by(name: 'free')
  end

  def monthly_token_limit
    effective_license_type.monthly_token_limit
  end

  def max_conversations_per_day
    effective_license_type.max_conversations_per_day
  end

  def max_iterations_per_conversation
    effective_license_type.max_iterations_per_conversation || AppConfig.current.max_iterations
  end

  # Token tracking
  def add_user_token_usage(tokens_used)
    reset_user_counter_if_needed
    
    transaction do
      increment!(:current_month_tokens_used, tokens_used)
    end
    
    Rails.logger.info "User #{id} (#{effective_license_type.display_name}): Added #{tokens_used} tokens. Total: #{current_month_tokens_used}/#{monthly_token_limit}"
  end

  def user_tokens_remaining
    [monthly_token_limit - current_month_tokens_used, 0].max
  end

  def user_limit_exceeded?
    current_month_tokens_used >= monthly_token_limit
  end

  def user_usage_percentage
    return 0 if monthly_token_limit == 0
    ((current_month_tokens_used.to_f / monthly_token_limit) * 100).round(2)
  end

  def reset_user_counter_if_needed
    current_month = Date.current.beginning_of_month
    
    if user_month_start != current_month
      update_columns(
        current_month_tokens_used: 0,
        user_month_start: current_month
      )
      Rails.logger.info "User #{id}: Reset monthly token counter for #{current_month}"
    end
  end

  # Conversation limits
  def conversations_today
    conversations.where(created_at: Date.current.all_day).count
  end

  def can_create_conversation?
    return true if effective_license_type.unlimited_conversations?
    conversations_today < max_conversations_per_day
  end

  def conversations_remaining_today
    return Float::INFINITY if effective_license_type.unlimited_conversations?
    [max_conversations_per_day - conversations_today, 0].max
  end

  # License management
  def license_active?
    return true if license_expires_at.nil? # Free or lifetime licenses
    license_expires_at > Time.current
  end

  def license_expired?
    !license_active?
  end

  def days_until_license_expires
    return Float::INFINITY if license_expires_at.nil?
    ((license_expires_at - Time.current) / 1.day).ceil
  end

  def upgrade_license!(new_license_type, duration_months = 1)
    transaction do
      # If upgrading from free, set expiration
      if effective_license_type.free_license? && !new_license_type.free_license?
        self.license_expires_at = duration_months.months.from_now
      elsif license_expires_at.present?
        # Extend existing license
        base_time = license_expired? ? Time.current : license_expires_at
        self.license_expires_at = base_time + duration_months.months
      end
      
      self.license_type = new_license_type
      self.license_auto_renew = true
      save!
    end
  end

  def downgrade_to_free!
    transaction do
      self.license_type = LicenseType.find_by(name: 'free')
      self.license_expires_at = nil
      self.license_auto_renew = false
      save!
    end
  end

  def token_usage_info
    {
      license_type: {
        name: effective_license_type.name,
        display_name: effective_license_type.display_name,
        monthly_token_limit: monthly_token_limit,
        price_per_month: effective_license_type.price_per_month
      },
      usage: {
        used_this_month: current_month_tokens_used,
        remaining: user_tokens_remaining,
        usage_percentage: user_usage_percentage,
        limit_exceeded: user_limit_exceeded?
      },
      license_status: {
        active: license_active?,
        expires_at: license_expires_at,
        days_remaining: days_until_license_expires,
        auto_renew: license_auto_renew
      },
      limits: {
        conversations_today: conversations_today,
        max_conversations_per_day: max_conversations_per_day,
        conversations_remaining_today: conversations_remaining_today,
        max_iterations_per_conversation: max_iterations_per_conversation
      },
      month_start: user_month_start
    }
  end

  def feature_enabled?(feature_name)
    effective_license_type.feature_enabled?(feature_name)
  end

  # Helper method to get join date
  def join_date
    created_at&.strftime('%B %Y')
  end

  private

  def assign_default_license
    return if license_type.present?
    
    free_license = LicenseType.find_by(name: 'free')
    if free_license
      self.update_column(:license_type_id, free_license.id)
    end
  end
end
