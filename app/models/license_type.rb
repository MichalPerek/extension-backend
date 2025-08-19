class LicenseType < ApplicationRecord
  has_many :accounts, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-z_]+\z/ }
  validates :display_name, presence: true
  validates :monthly_token_limit, presence: true, numericality: { greater_than: 0 }
  validates :price_per_month, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :max_conversations_per_day, numericality: { greater_than: 0 }, allow_nil: true
  validates :max_iterations_per_conversation, numericality: { greater_than: 0 }, allow_nil: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:sort_order, :name) }

  # Predefined license types
  BUILTIN_LICENSES = {
    free: {
      display_name: 'Free',
      description: 'Basic usage with limited tokens',
      monthly_token_limit: 10_000,
      price_per_month: 0.0,
      max_conversations_per_day: 10,
      max_iterations_per_conversation: 5,
      features: { 'priority_support' => false, 'advanced_models' => false }
    },
    basic: {
      display_name: 'Basic',
      description: 'Increased token limit for regular users',
      monthly_token_limit: 100_000,
      price_per_month: 9.99,
      max_conversations_per_day: 50,
      max_iterations_per_conversation: 10,
      features: { 'priority_support' => false, 'advanced_models' => true }
    },
    pro: {
      display_name: 'Pro',
      description: 'High usage limits for power users',
      monthly_token_limit: 500_000,
      price_per_month: 29.99,
      max_conversations_per_day: nil, # unlimited
      max_iterations_per_conversation: nil, # use global default
      features: { 'priority_support' => true, 'advanced_models' => true }
    },
    enterprise: {
      display_name: 'Enterprise',
      description: 'Unlimited usage for businesses',
      monthly_token_limit: 10_000_000,
      price_per_month: 99.99,
      max_conversations_per_day: nil,
      max_iterations_per_conversation: nil,
      features: { 'priority_support' => true, 'advanced_models' => true, 'custom_models' => true }
    }
  }.freeze

  # Create or update builtin license types
  def self.seed_builtin_licenses!
    BUILTIN_LICENSES.each_with_index do |(name, attributes), index|
      license = find_or_initialize_by(name: name.to_s)
      license.assign_attributes(
        attributes.merge(
          sort_order: index,
          active: true
        )
      )
      license.save!
    end
  end

  def free_license?
    name == 'free'
  end

  def unlimited_conversations?
    max_conversations_per_day.nil?
  end

  def unlimited_iterations?
    max_iterations_per_conversation.nil?
  end

  def effective_max_iterations
    max_iterations_per_conversation || AppConfig.current.max_iterations
  end

  def feature_enabled?(feature_name)
    features[feature_name.to_s] == true
  end

  def to_api_hash
    {
      id: id,
      name: name,
      display_name: display_name,
      description: description,
      monthly_token_limit: monthly_token_limit,
      price_per_month: price_per_month,
      max_conversations_per_day: max_conversations_per_day,
      max_iterations_per_conversation: max_iterations_per_conversation,
      features: features,
      active: active
    }
  end
end
