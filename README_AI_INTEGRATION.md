# AI Processing Integration - Backend (Global LLM Models)

This document describes the AI processing integration implemented in the Rails backend using a global LLM model configuration system.

## Setup Instructions

### 1. Environment Configuration

Add your OpenAI API key to your environment:

```bash
# Add to .env or export in your shell
export OPENAI_API_KEY="sk-your-openai-api-key-here"
```

### 2. Database Migration

The AI settings table has been created. If you need to run migrations:

```bash
rails db:migrate
```

### 3. Test the Integration

Start the Rails server:

```bash
rails server
```

## API Endpoints

### Process AI Prompt
```
POST /api/ai/process
Authorization: Bearer <token>
Content-Type: application/json

{
  "userInput": "Hello, how are you?",
  "instruction": "Translate this to Spanish",
  "model": "1" // LLM model ID from global configuration
}

Response:
{
  "result": "Hola, ¿cómo estás?",
  "model": "gpt-3.5-turbo",
  "provider": "openai",
  "modelName": "GPT-3.5 Turbo",
  "usage": {
    "promptTokens": 15,
    "completionTokens": 8,
    "totalTokens": 23
  },
  "processingTime": 1250.5
}
```

### Get Available Models (Grouped by Provider)
```
GET /api/ai/models
Authorization: Bearer <token>

Response:
[
  {
    "id": "openai",
    "name": "Openai",
    "enabled": true,
    "models": [
      {
        "id": 1,
        "name": "GPT-3.5 Turbo",
        "provider": "openai",
        "model_id": "gpt-3.5-turbo",
        "full_identifier": "openai:gpt-3.5-turbo",
        "enabled": true
      },
      {
        "id": 2,
        "name": "GPT-4",
        "provider": "openai",
        "model_id": "gpt-4",
        "full_identifier": "openai:gpt-4",
        "enabled": true
      }
    ]
  }
]
```

### Get Available Models (Flat List)
```
GET /api/ai/available_models
Authorization: Bearer <token>

Response:
[
  {
    "id": 1,
    "name": "GPT-3.5 Turbo",
    "provider": "openai",
    "model_id": "gpt-3.5-turbo",
    "full_identifier": "openai:gpt-3.5-turbo",
    "enabled": true
  },
  {
    "id": 2,
    "name": "GPT-4",
    "provider": "openai",
    "model_id": "gpt-4",
    "full_identifier": "openai:gpt-4",
    "enabled": true
  }
]
```

### Test Model Connection
```
POST /api/ai/test/1
Authorization: Bearer <token>

Response:
{
  "success": true,
  "message": "Connection successful. Model: gpt-3.5-turbo"
}
```

## Code Structure

### Models
- `LlmModel` - Stores global LLM configurations with prompts, models, and settings
- `Account` - No AI-specific relationships (users select from global models)

### Controllers
- `Api::Ai::ProcessingController` - Handles all AI-related endpoints

### Services
- `OpenaiService` - OpenAI API integration
- `AnthropicService` - Placeholder for Anthropic integration

## Key Features

### 1. Global LLM Model Configuration
- Centralized configuration for all AI models
- Admin-controlled prompts, temperature, and model settings
- Users select from available global models

### 2. Modular Provider System
- Easy to add new AI providers by creating new service classes
- Each model can have custom configurations stored in JSONB

### 3. API Key Management
- Global API keys via environment variables
- No user-specific key storage (simplified security model)

### 4. Model-Specific Prompts
- Each LLM model has its own system prompt
- User instructions are combined with model prompts
- Fine-tuned configurations per model (temperature, max_tokens, etc.)

### 5. Error Handling
- Comprehensive error handling for API failures
- Timeout protection
- Rate limit handling

### 6. Usage Tracking
- Token usage reporting
- Processing time measurement
- Provider/model tracking

## Security Considerations

- All endpoints require authentication
- API keys are stored securely
- Input validation prevents malicious prompts
- Rate limiting handled by providers

## Adding New Providers

### 1. Create Service Class

```ruby
class NewProviderService
  def initialize(user_ai_settings = nil, model = nil)
    @user_ai_settings = user_ai_settings
    @model = model || default_model
    @api_key = get_api_key
  end

  def process_prompt(user_input, instruction)
    # Implement API call to new provider
    {
      text: "processed_text",
      model: @model,
      provider: "new_provider",
      usage: { promptTokens: 0, completionTokens: 0, totalTokens: 0 }
    }
  end

  def test_connection
    # Test the connection
    "Connection successful"
  end

  private

  def get_api_key
    user_key = @user_ai_settings&.providers&.dig('new_provider', 'apiKey')
    user_key.presence || ENV['NEW_PROVIDER_API_KEY']
  end

  def default_model
    @user_ai_settings&.providers&.dig('new_provider', 'defaultModel') || 'default-model'
  end
end
```

### 2. Update Controller

Add the new provider to `get_ai_provider_service` method in the controller.

### 3. Add LLM Model Configuration

Create a new LLM model entry in the database:

```ruby
LlmModel.create!(
  name: 'New Provider Model',
  provider: 'new_provider',
  model_id: 'new-model-v1',
  prompt: 'You are a helpful assistant using the new provider.',
  config: {
    'temperature' => 0.7,
    'max_tokens' => 1000,
    'custom_param' => 'value'
  },
  enabled: true
)
```

## Testing

Test the integration manually:

```bash
# Get auth token first
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"your@email.com","password":"password"}'

# Get available models
curl -X GET http://localhost:3000/api/ai/available_models \
  -H "Authorization: Bearer YOUR_TOKEN"

# Test AI processing with model ID
curl -X POST http://localhost:3000/api/ai/process \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "userInput": "Hello world",
    "instruction": "Translate to Spanish",
    "model": "1"
  }'
```

## Error Handling

Common error responses:

```json
// Missing API key
{
  "error": "OpenAI API key not configured"
}

// Invalid request
{
  "error": "User input and instruction are required"
}

// Provider error
{
  "error": "OpenAI API error: Rate limit exceeded"
}
```

## Global LLM Model Structure

Each LLM model in the database contains:

```ruby
# LlmModel fields:
# - name: Human-readable name (e.g., "GPT-4 Turbo")
# - provider: Provider identifier (e.g., "openai", "anthropic")
# - model_id: Provider's model identifier (e.g., "gpt-4-turbo")
# - prompt: System prompt for this model
# - config: JSONB field with model-specific settings:
#   {
#     "temperature": 0.7,
#     "max_tokens": 2000,
#     "top_p": 1.0,
#     "frequency_penalty": 0.0,
#     "presence_penalty": 0.0
#   }
# - enabled: Whether this model is available for use

# Example:
LlmModel.create!(
  name: "GPT-4 Turbo",
  provider: "openai",
  model_id: "gpt-4-turbo",
  prompt: "You are an advanced AI assistant. Provide comprehensive and well-structured responses.",
  config: {
    "temperature" => 0.7,
    "max_tokens" => 2000,
    "top_p" => 1.0,
    "frequency_penalty" => 0.0,
    "presence_penalty" => 0.0
  },
  enabled: true
)
```

## Performance Considerations

- API requests are made synchronously for simplicity
- Global model configurations are cached by Rails
- Consider adding background job processing for long requests
- Monitor API usage and costs per model
- Each model can have different rate limits and costs

## Admin Management

To manage LLM models:

```ruby
# Add new model
LlmModel.create!(name: "New Model", provider: "openai", ...)

# Disable model
LlmModel.find_by(model_id: "old-model").update!(enabled: false)

# Update model configuration
model = LlmModel.find_by(model_id: "gpt-4")
model.update!(config: model.config.merge("temperature" => 0.5))
```

This global configuration system provides centralized control over AI models while allowing users to select from available options.
