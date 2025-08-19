require 'net/http'
require 'json'

class OpenaiService
  OPENAI_API_URL = 'https://api.openai.com/v1/chat/completions'
  
  def initialize
    @api_key = get_api_key
  end

  def process_prompt(user_input, instruction, llm_model)
    if @api_key.blank?
      raise "OpenAI API key not configured"
    end

    messages = build_messages(user_input, instruction, llm_model)
    
    response = make_api_request(messages, llm_model)
    raw_content = response['choices'][0]['message']['content']
    
    # Parse the JSON response from the AI
    begin
      parsed_response = JSON.parse(raw_content)
      
      # Validate required fields
      unless parsed_response.is_a?(Hash) && 
             parsed_response['result_text'] && 
             parsed_response['instruction'] && 
             parsed_response['original_text']
        raise "Invalid JSON response structure from AI"
      end
      
      {
        text: parsed_response['result_text'],
        instruction: parsed_response['instruction'],
        original_text: parsed_response['original_text'],
        language: parsed_response['language'],
        task_summary: parsed_response['task_summary'],
        model: response['model'],
        provider: 'openai',
        usage: {
          promptTokens: response.dig('usage', 'prompt_tokens'),
          completionTokens: response.dig('usage', 'completion_tokens'),
          totalTokens: response.dig('usage', 'total_tokens')
        }
      }
    rescue JSON::ParserError => e
      # Fallback if AI doesn't return valid JSON
      Rails.logger.warn "AI returned non-JSON response: #{raw_content}"
      {
        text: raw_content,
        instruction: instruction,
        original_text: user_input,
        language: 'en',
        task_summary: 'Text transformation',
        model: response['model'],
        provider: 'openai',
        usage: {
          promptTokens: response.dig('usage', 'prompt_tokens'),
          completionTokens: response.dig('usage', 'completion_tokens'),
          totalTokens: response.dig('usage', 'total_tokens')
        }
      }
    end
  end

  def test_connection(llm_model)
    if @api_key.blank?
      raise "OpenAI API key not configured"
    end

    # Simple test with minimal request
    messages = [{ role: 'user', content: 'Test' }]
    
    begin
      # Use a minimal configuration for testing
      test_config = {
        model: llm_model.model_id,
        messages: messages,
        max_tokens: 5,
        temperature: 0.7
      }
      
      response = make_direct_api_request(test_config)
      "Connection successful. Model: #{response['model']}"
    rescue => e
      raise "Connection failed: #{e.message}"
    end
  end

  private

  def get_api_key
    ENV['OPENAI_API_KEY']
  end

  def build_messages(user_input, instruction, llm_model)
    # Use the LLM model's configured prompt as system message
    system_prompt = llm_model.prompt

    # Format the user message with both the instruction and the original text
    user_message = "INSTRUCTION: #{instruction}\n\nORIGINAL TEXT:\n#{user_input}"

    [
      {
        role: 'system',
        content: system_prompt
      },
      {
        role: 'user',
        content: user_message
      }
    ]
  end

  def make_api_request(messages, llm_model)
    request_body = {
      model: llm_model.model_id,
      messages: messages,
      max_tokens: llm_model.max_tokens,
      temperature: llm_model.temperature
    }

    # Add any additional config from the LLM model
    llm_model.config.each do |key, value|
      next if %w[max_tokens temperature].include?(key) # Already handled above
      request_body[key.to_sym] = value
    end

    make_direct_api_request(request_body)
  end

  def make_direct_api_request(request_body)
    uri = URI(OPENAI_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30

    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{@api_key}"
    request['Content-Type'] = 'application/json'
    request.body = request_body.to_json

    response = http.request(request)
    
    unless response.code == '200'
      error_data = JSON.parse(response.body) rescue {}
      error_message = error_data.dig('error', 'message') || "HTTP #{response.code}: #{response.message}"
      raise error_message
    end

    JSON.parse(response.body)
  rescue JSON::ParserError => e
    raise "Invalid response from OpenAI API: #{e.message}"
  rescue Net::TimeoutError => e
    raise "Request timeout: #{e.message}"
  rescue => e
    raise "OpenAI API error: #{e.message}"
  end
end
