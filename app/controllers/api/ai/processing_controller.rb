class Api::Ai::ProcessingController < ApplicationController
  before_action :require_authentication

  def process_prompt
    user_input = params[:userInput]
    instruction = params[:instruction]
    model_identifier = params[:model] # This is now the LLM model identifier
    conversation_id = params[:conversationId] # Optional: for continuing an existing conversation
    session_id = params[:sessionId] # Optional: for grouping related conversations

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
      
      # Find or create conversation
      conversation = find_or_create_conversation(
        user_input: user_input,
        conversation_id: conversation_id,
        session_id: session_id
      )
      
      # Check if conversation can accept more iterations
      unless conversation.can_add_iteration?
        render json: { 
          error: "Maximum #{Conversation::MAX_ITERATIONS} iterations per conversation exceeded. Please start a new conversation.",
          max_iterations: Conversation::MAX_ITERATIONS,
          current_count: conversation.iteration_count,
          conversation_id: conversation.id
        }, status: :unprocessable_entity
        return
      end

      # Add iteration to conversation
      iteration = conversation.add_iteration(
        instruction: result[:instruction],
        result_text: result[:text],
        language: result[:language],
        task_summary: result[:task_summary],
        model: llm_model.model_id,
        provider: llm_model.provider,
        model_name: llm_model.name,
        usage: result[:usage],
        processing_time: processing_time
      )
      
      render json: {
        result: result[:text],
        instruction: result[:instruction],
        original_text: result[:original_text],
        language: result[:language],
        task_summary: result[:task_summary],
        model: llm_model.model_id,
        provider: llm_model.provider,
        modelName: llm_model.name,
        usage: result[:usage],
        processingTime: processing_time,
        conversationId: conversation.id,
        sessionId: conversation.session_id,
        iterationId: iteration['id'],
        iterationCount: conversation.iteration_count,
        iterationsRemaining: conversation.iterations_remaining,
        canAddIteration: conversation.can_add_iteration?
      }
    rescue ArgumentError => e
      Rails.logger.warn "AI Processing Input Error: #{e.message}"
      render json: { error: e.message }, status: :bad_request
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

  def find_or_create_conversation(user_input:, conversation_id: nil, session_id: nil)
    current_account = rodauth.rails_account
    
    # If conversation_id is provided, try to find existing conversation
    if conversation_id.present?
      existing_conversation = current_account.conversations.find_by(id: conversation_id)
      return existing_conversation if existing_conversation
    end
    
    # Find or create conversation using the model's logic
    Conversation.find_or_create_for_iteration(
      account: current_account,
      original_text: user_input,
      session_id: session_id
    )
  end

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
