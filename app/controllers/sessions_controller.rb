class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    if user&.authenticate(params.dig(:session, :password))
      log_in user
      params.dig(:session, :remember_me) == "1" ? remember(user) : forget(user)
      redirect_back_or user
    else
      flash.now[:danger] = t "Invalid email/password combination"
      render "new"
    end
  end

  def destroy
    log_out
    redirect_to root_url, status: :see_other
  end
end
