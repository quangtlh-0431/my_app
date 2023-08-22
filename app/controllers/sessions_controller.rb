class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    authenticate_user user
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def authenticate_user user
    if user&.authenticate(params[:session][:password])
      reset_and_remember user
      redirect_to user
    else
      handle_invalid_login
    end
  end

  def handle_invalid_login
    flash.now[:danger] = t("invalid_email_password_combination")
    render :new, status: :forbidden
  end

  def reset_and_remember user
    reset_session
    remember_or_forget user
    log_in user
  end

  def remember_or_forget user
    params[:session][:remember_me] == "1" ? remember(user) : forget(user)
  end
end
