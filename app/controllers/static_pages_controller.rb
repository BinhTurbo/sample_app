class StaticPagesController < ApplicationController
  def home
    return unless logged_in?

    @micropost = current_user.microposts.build
    @pagy, @feed_items = pagy current_user.feed.recent_posts,
                              items: Settings.default.page_10
  end

  def help; end

  def about; end

  def contact; end
end
