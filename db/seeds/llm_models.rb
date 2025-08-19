# Create default LLM models with global configurations

# OpenAI Models
LlmModel.find_or_create_by(provider: 'openai', model_id: 'gpt-3.5-turbo') do |model|
  model.name = 'GPT-3.5 Turbo'
  model.prompt = 'You are a helpful assistant. Follow the user\'s instructions carefully and provide accurate, helpful responses.'
  model.config = {
    'temperature' => 0.7,
    'max_tokens' => 1000,
    'top_p' => 1.0,
    'frequency_penalty' => 0.0,
    'presence_penalty' => 0.0
  }
  model.enabled = true
end

LlmModel.find_or_create_by(provider: 'openai', model_id: 'gpt-4') do |model|
  model.name = 'GPT-4'
  model.prompt = 'You are a highly capable AI assistant. Provide detailed, accurate, and thoughtful responses to user queries.'
  model.config = {
    'temperature' => 0.7,
    'max_tokens' => 2000,
    'top_p' => 1.0,
    'frequency_penalty' => 0.0,
    'presence_penalty' => 0.0
  }
  model.enabled = true
end

LlmModel.find_or_create_by(provider: 'openai', model_id: 'gpt-4-turbo') do |model|
  model.name = 'GPT-4 Turbo'
  model.prompt = 'You are an advanced AI assistant. Provide comprehensive and well-structured responses.'
  model.config = {
    'temperature' => 0.7,
    'max_tokens' => 2000,
    'top_p' => 1.0,
    'frequency_penalty' => 0.0,
    'presence_penalty' => 0.0
  }
  model.enabled = true
end

# Anthropic Models (for future implementation)
LlmModel.find_or_create_by(provider: 'anthropic', model_id: 'claude-3-sonnet') do |model|
  model.name = 'Claude 3 Sonnet'
  model.prompt = 'You are Claude, an AI assistant created by Anthropic. Provide helpful, harmless, and honest responses.'
  model.config = {
    'temperature' => 0.7,
    'max_tokens' => 1000,
    'top_p' => 1.0
  }
  model.enabled = false # Disabled until implemented
end

LlmModel.find_or_create_by(provider: 'anthropic', model_id: 'claude-3-opus') do |model|
  model.name = 'Claude 3 Opus'
  model.prompt = 'You are Claude, an advanced AI assistant. Provide detailed and thoughtful responses.'
  model.config = {
    'temperature' => 0.7,
    'max_tokens' => 2000,
    'top_p' => 1.0
  }
  model.enabled = false # Disabled until implemented
end

puts "Created #{LlmModel.count} LLM models"
puts "Enabled models: #{LlmModel.enabled.count}"
