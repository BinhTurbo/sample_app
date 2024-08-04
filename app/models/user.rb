class User < ApplicationRecord
  validates :name, presence: true, length: {maximum: 50}
  validates :email,
            presence: true,
            length: {maximum: 255},
            format: {with: Settings.email_regex},
            uniqueness: true

  attr_accessor :remember_token, :activation_token, :reset_token

  before_save :downcase_email
  before_create :create_activation_digest
  has_many :microposts, dependent: :destroy
  has_secure_password

  def feed
    microposts
  end

  def password_reset_expired?
    expiration_hours = Settings.default.password_reset_expiration_hours
    message = "Password reset expiration hours: #{expiration_hours.inspect}"
    Rails.logger.info(message)
    if expiration_hours.nil?
      Rails.logger.error "password_reset_expiration_hours is nil"
      return false
    end
    reset_sent_at < expiration_hours.hours.ago
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(
      reset_digest: User.digest(reset_token),
      reset_sent_at: Time.zone.now
    )
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  scope :ordered_by_creation, ->{order(created_at: :asc)}
  # Activates an account.
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  class << self
    # Returns the hash digest of the given string.
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create(string, cost:)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  # Returns true if the given token matches the digest.
  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false unless digest

    BCrypt::Password.new(digest).is_password?(token)
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  # Forgets a user.
  def forget
    update_column :remember_digest, nil
  end

  private

  def downcase_email
    email.downcase
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
