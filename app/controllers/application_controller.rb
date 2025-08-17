class ApplicationController < ActionController::API
  private
  
  # Helper method to require authentication
  def require_authentication
    if jwt_token.nil? || current_account.nil?
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
  
  # Get current account from JWT token
  def current_account
    return @current_account if defined?(@current_account)
    
    @current_account = Account.find_by(id: jwt_account_id) if jwt_account_id
  end
  
  # Extract JWT token from Authorization header
  def jwt_token
    return @jwt_token if defined?(@jwt_token)
    
    auth_header = request.headers['Authorization']
    @jwt_token = auth_header&.split(' ')&.last if auth_header&.start_with?('Bearer ')
  end
  
  # Get account ID from JWT token
  def jwt_account_id
    return nil unless jwt_token
    
    begin
      payload = JWT.decode(jwt_token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })
      payload[0]['account_id']
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end
  end
end
