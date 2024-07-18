class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def index; end

  def show
    return if @user

    flash[:warning] = t("user_not_found")
    redirect_to root_path
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = t("user_created")
      redirect_to @user
    else
      respond_to do |format|
        format.html{render :new, status: :unprocessable_entity}
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            @user,
            partial: "users/form",
            locals: {user: @user}
          )
        end
      end
    end
  end

  private

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
end
