class LlmModel < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :provider, presence: true, inclusion: { in: %w[openai anthropic groq] }
  validates :model_id, presence: true
  validates :prompt, presence: true
  validates :provider, uniqueness: { scope: :model_id }

  # Scopes
  scope :enabled, -> { where(enabled: true) }
  scope :by_provider, ->(provider) { where(provider: provider) }

  # Class methods
  def self.for_provider(provider)
    enabled.by_provider(provider)
  end

  def self.find_by_model_identifier(identifier)
    # identifier can be "provider:model_id" or just "model_id"
    if identifier.include?(':')
      provider, model_id = identifier.split(':', 2)
      find_by(provider: provider, model_id: model_id, enabled: true)
    else
      find_by(model_id: identifier, enabled: true)
    end
  end

  # Instance methods
  def full_identifier
    "#{provider}:#{model_id}"
  end

  def temperature
    config['temperature'] || 0.7
  end

  def max_tokens
    config['max_tokens'] || 1000
  end

  def to_api_hash
    {
      id: id,
      name: name,
      provider: provider,
      model_id: model_id,
      full_identifier: full_identifier,
      enabled: enabled
    }
  end

  # Helper method to enable/disable parameters
  def enable_parameter(param_name, value = nil)
    config[param_name] = value if value
    config["#{param_name}_enabled"] = true
    save!
  end

  def disable_parameter(param_name)
    config["#{param_name}_enabled"] = false
    save!
  end

  def parameter_enabled?(param_name)
    config["#{param_name}_enabled"] == true
  end

  # Get effective configuration (only enabled parameters)
  def effective_config
    effective = {}
    
    # All parameters are now conditional
    %w[max_completion_tokens temperature top_p frequency_penalty presence_penalty max_tokens].each do |param|
      if parameter_enabled?(param) && config[param]
        effective[param] = config[param]
      end
    end
    
    effective
  end
end
