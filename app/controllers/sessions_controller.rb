class SessionsController < ApplicationController
  def new; end

  def create
    user = find_user_by_email
    if user_authenticated?(user)
      process_authenticated_user(user)
    else
      handle_invalid_login
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end

  private

  def find_user_by_email
    User.find_by(email: params.dig(:session, :email)&.downcase)
  end

  def user_authenticated? user
    user&.authenticate(params.dig(:session, :password))
  end

  def process_authenticated_user user
    if user.activated?
      log_in user
      params.dig(:session, :remember_me) == "1" ? remember(user) : forget(user)
      redirect_back_or user
    else
      handle_unactivated_user
    end
  end

  def handle_unactivated_user
    flash[:warning] = t("flash.warning.account_not_activated")
    redirect_to root_url, status: :see_other
  end

  def handle_invalid_login
    flash.now[:danger] = t("flash.danger.invalid_login")
    render "new"
  end
end
