class Api::UsersController < ApplicationController
  before_action :require_authentication

  def profile
    render json: {
      user: {
        id: current_account.id,
        name: current_account.name,
        email: current_account.email,
        joinDate: current_account.join_date
      }
    }
  end
end
