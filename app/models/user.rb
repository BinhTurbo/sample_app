class User < ApplicationRecord
  # validates :name, presence: true, length: {minimum: 3, maximum: 50}

  # after_update :run_callback_after_update

  # def run_callback_after_update
  #   Rails.logger.info "Callback after update"
  # end

  # before_save :downcase_email

  # before_save :test_callback_before_save
  # around_save :test_callback_around_save
  # after_save :test_callback_after_save

  # def test_callback_before_save
  #   Rails.logger.info "Callback before save"
  # end

  # def test_callback_around_save
  #   Rails.logger.info "Callback in around save"
  #   yield # User saved
  #   Rails.logger.info "Callback out around save"
  # end

  # def test_callback_after_save
  #   Rails.logger.info "Callback after save"
  #   raise "Error in after save"
  # end

  # def downcase_email
  #   self.email = email.downcase!
  # end

  # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, presence: true, length: {maximum: 50}
  validates :email,
            presence: true,
            length: {maximum: 255},
            format: {with: Settings.email_regex},
            uniqueness: true

  before_save :downcase_email
  has_secure_password
  attr_accessor :remember_token

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

  def authenticated? remember_token
    BCrypt::Password.new(remember_digest).is_password? remember_token
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
end
