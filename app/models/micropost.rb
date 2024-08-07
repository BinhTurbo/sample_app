class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    resize_params = Settings.default.image.resize_to_limit
    attachable.variant :display, resize_to_limit: resize_params
  end
  content_type_message = I18n.t("activerecord.errors.models.attributes.content")
  size_message = I18n.t("activerecord.errors.models.attributes.size")
  validates :content, presence: true,
length: {maximum: Settings.default.digit_140}
  validates :image, content_type: {
                      in: %w(image/jpeg image/gif image/png),
                      message: content_type_message
                    },
  size: {
    less_than: 5.megabytes,
    message: size_message
  }

  # Named scope for recent posts
  scope :recent_posts, ->{order created_at: :desc}
  scope :relate_post, ->(user_ids){where user_id: user_ids}
end
