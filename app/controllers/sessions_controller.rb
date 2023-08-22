class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    if user&.authenticate params.dig(:session, :password)
      reset_session
      log_in user
      redirect_to user
    else
      flash.now[:danger] = t "invalid_email_password_combination"
      render :new, status: :forbidden
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
