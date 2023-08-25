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
      if user.activated?
        forwarding_url = session[:forwarding_url]
        reset_and_remember user
        redirect_to forwarding_url || user
      else
        message  = t("account_not_activated")
        message += t("check_your_email_for_the_activation_link")
        flash[:warning] = message
        redirect_to root_url
      end
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
