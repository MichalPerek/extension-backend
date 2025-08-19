class AnthropicService
  def initialize(user_ai_settings = nil, model = nil)
    @user_ai_settings = user_ai_settings
    @model = model || default_model
    @api_key = get_api_key
  end

  def process_prompt(user_input, instruction)
    raise "Anthropic integration not yet implemented"
  end

  def test_connection
    raise "Anthropic integration not yet implemented"
  end

  private

  def get_api_key
    user_key = @user_ai_settings&.providers&.dig('anthropic', 'apiKey')
    user_key.presence || ENV['ANTHROPIC_API_KEY']
  end

  def default_model
    @user_ai_settings&.providers&.dig('anthropic', 'defaultModel') || 'claude-3-sonnet'
  end
end
