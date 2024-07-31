class UsersController < ApplicationController
  include Pagy::Backend
  before_action :logged_in_user, except: %i(new create)
  before_action :find_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @pagy, @users = pagy(User.ordered_by_creation, items: Settings.page_10)
  end

  def show
    return if @user

    flash[:warning] = t("user_not_found")
    redirect_to root_path
  end

  def new
    @user = User.new
  end

  def edit; end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = t "Please check your email to activate your account."
      redirect_to root_url, status: :see_other
    else
      render :new
    end
  end

  def update
    if @user.update(user_params)
      # Handle a successful update
      flash[:success] = t "Profile updated"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "User deleted"
    else
      flash[:danger] = t "Delete fail!"
    end
    redirect_to users_path
  end

  private
  def admin_user
    redirect_to root_path unless current_user.admin?
  end

  def set_user
    @user = User.find_by(id: params[:id])
  end

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation
    )
  end

  def find_user
    @user = User.find_by(id: params[:id])
    redirect_to root_path unless @user
  end

  # Before filters
  # Confirms a logged-in user
  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "Please log in."
    redirect_to login_url
  end

  # Confirms the correct user
  def correct_user
    return if current_user?(@user)

    flash[:error] = t "You cannot edit this account."
    redirect_to root_url
  end
end
