class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :find_user, only: %i(edit update show destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:success] = t "welcome_to_the_sample_app!"
      redirect_to @user
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = t("Profile_updated")
      redirect_to @user
    else
      render "edit", status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t("User_deleted")
    else
      flash[:danger] = t("failed")
    end
    redirect_to users_url, status: :see_other
  end

  private

  def user_params
    params.require(:user).permit :name,
                                 :email,
                                 :password,
                                 :password_confirmation
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t("Please_log_in")
    redirect_to login_url, status: :see_other
  end

  def correct_user
    redirect_to(root_url, status: :see_other) unless current_user? @user
  end

  def admin_user
    return if current_user.admin?

    flash[:warning] = t("You_are_not_admin")
    redirect_to(root_url, status: :see_other)
  end

  def find_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t "Not_found_user"
    redirect_to root_path
  end
end
