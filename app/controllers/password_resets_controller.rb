class PasswordResetsController < ApplicationController
  before_action :load_user,
                :valid_user,
                :check_expiration,
                only: %i(edit update)
  def new; end

  def edit; end

  def create
    @user = User.find_by email: params.dig(:password_reset, :email).downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t("email_sent_with_password_reset_instructions")
      redirect_to root_url
    else
      flash.now[:danger] = t("email_address_not_found")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, t("can_not_be_empty"))
      render :edit, status: :unprocessable_entity
    elsif @user.update(user_params)
      reset_session
      log_in @user
      flash[:success] = t("password_has_been_reset")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def load_user
    @user = User.find_by email: params[:email]
    return if @user

    flash[:danger] = t("Not_found_user")
    redirect_to root_url
  end

  def valid_user
    return if @user.activated? && @user.authenticated?(:reset, params[:id])

    flash[:danger] = t("account_not_activated")
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t("password_reset_has_expired")
    redirect_to new_password_reset_url
  end
end
