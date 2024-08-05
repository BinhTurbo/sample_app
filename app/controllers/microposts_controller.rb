class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy

  def create
    @micropost = build_micropost
    if @micropost.save
      handle_success
    else
      handle_failure
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = I18n.t("flash.success.micropost_deleted")
    else
      flash[:danger] = I18n.t("flash.danger.delete_failed")
    end
    redirect_to request.referer || root_url
  end

  private

  def build_micropost
    micropost = current_user.microposts.build(micropost_params)
    micropost.image.attach(params.dig(:micropost, :image))
    micropost
  end

  def handle_success
    flash[:success] = I18n.t("flash.success.micropost_created")
    show_feed
  end

  def handle_failure
    show_feed
    render "static_pages/home", status: :unprocessable_entity
  end

  def show_feed
    feed = current_user.microposts
    items_per_page = Settings.default.page_10
    @pagy, @feed_items = pagy(feed, items: items_per_page)
  end

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    return if @micropost

    flash[:danger] = I18n.t("flash.danger.micropost_invalid")
    redirect_to request.referer || root_url
  end

  def micropost_params
    params.require(:micropost).permit(:content, :image)
  end
end
