class Account < ApplicationRecord
  include Rodauth::Rails.model
  
  # Helper method to get join date
  def join_date
    created_at&.strftime('%B %Y')
  end
end
