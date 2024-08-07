class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(new create show)
  before_action :find_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy
  def index
    @pagy, @users = pagy(User.ordered_by_creation,
                         items: Settings.default.page_10)
  end

  def show
    @pagy, @microposts = pagy @user.microposts, items: Settings.default.page_10
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

  def following
    @title = "Following"
    items_per_page = Settings.pagination.items_per_page
    @pagy, @users = pagy @user.following, items: items_per_page
    render :show_follow
  end

  def followers
    @title = "Followers"
    items_per_page = Settings.pagination.items_per_page
    @pagy, @users = pagy @user.followers, items: items_per_page
    render :show_follow
  end

  private

  def admin_user
    redirect_to root_path unless current_user.admin?
  end

  def set_user
    @user = User.find_by(id: params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  def find_user
    @user = User.find_by(id: params[:id])
    redirect_to root_path unless @user
  end

  def correct_user
    return if current_user?(@user)

    flash[:error] = t "You cannot edit this account."
    redirect_to root_url
  end
end
