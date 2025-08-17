class ApplicationController < ActionController::API
  private
  
  # Helper method to require authentication
  def require_authentication
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
  
  # Get current account
  def current_account
    nil
  end
end
