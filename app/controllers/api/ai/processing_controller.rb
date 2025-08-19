class Api::Ai::ProcessingController < ApplicationController
  before_action :require_authentication

  def process_prompt
    user_input = params[:userInput]
    instruction = params[:instruction]
    model_identifier = params[:model] # This is now the LLM model identifier

    if user_input.blank? || instruction.blank?
      render json: { error: 'User input and instruction are required' }, status: :bad_request
      return
    end

    # Find the LLM model configuration
    llm_model = find_llm_model(model_identifier)
    unless llm_model
      render json: { error: 'Model not found or not enabled' }, status: :bad_request
      return
    end

    begin
      start_time = Time.current
      
      # Get the AI provider service with the LLM model configuration
      provider_service = get_ai_provider_service(llm_model)
      
      # Process the prompt using the LLM model's configuration
      result = provider_service.process_prompt(user_input, instruction, llm_model)
      
      processing_time = ((Time.current - start_time) * 1000).round(2) # milliseconds
      
      render json: {
        result: result[:text],
        model: llm_model.model_id,
        provider: llm_model.provider,
        modelName: llm_model.name,
        usage: result[:usage],
        processingTime: processing_time
      }
    rescue => e
      Rails.logger.error "AI Processing Error: #{e.message}"
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  def models
    # Return all available LLM models grouped by provider
    models_by_provider = LlmModel.enabled.group_by(&:provider)
    
    providers = models_by_provider.map do |provider_name, models|
      {
        id: provider_name,
        name: provider_name.capitalize,
        enabled: true,
        models: models.map(&:to_api_hash)
      }
    end
    
    render json: providers
  end

  def available_models
    # Return a flat list of all available models for selection
    models = LlmModel.enabled.map(&:to_api_hash)
    render json: models
  end

  def test_model
    model_identifier = params[:model_id]
    
    llm_model = find_llm_model(model_identifier)
    unless llm_model
      render json: { success: false, message: 'Model not found' }
      return
    end
    
    begin
      provider_service = get_ai_provider_service(llm_model)
      result = provider_service.test_connection(llm_model)
      
      render json: { success: true, message: result }
    rescue => e
      render json: { success: false, message: e.message }
    end
  end

  private



  def find_llm_model(model_identifier)
    return LlmModel.enabled.first if model_identifier.blank? # Default to first enabled model
    
    # Try to find by full identifier (provider:model_id) or just model_id
    LlmModel.find_by_model_identifier(model_identifier) || 
    LlmModel.enabled.find_by(id: model_identifier) # Allow finding by database ID too
  end

  def get_ai_provider_service(llm_model)
    case llm_model.provider
    when 'openai'
      OpenaiService.new
    when 'anthropic'
      AnthropicService.new
    else
      raise "Unknown AI provider: #{llm_model.provider}"
    end
  end
end
