class User < ApplicationRecord
  attr_accessor :remember_token

  before_save :downcase_email

  has_secure_password

  validates :email,
            presence: true,
            length: {maximum: Settings.digits.length_50},
            format: {with: Settings.regex_valid.email}
  validates :name, presence: true
  validate :birthday_within_last_100_years

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  def authenticated? remember_token
    return false if remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def session_token
    remember_digest || remember
  end

  private

  def birthday_within_last_100_years
    return unless birthday.present? && birthday < 100.years.ago.to_date

    errors.add :birthday, I18n.t("must_be_within_the_last_100_years")
  end

  def downcase_email
    email.downcase!
  end

  class << self
    def digest string
      cost_value = if ActiveModel::SecurePassword.min_cost
                     BCrypt::Engine::MIN_COST
                   else
                     BCrypt::Engine.cost
                   end
      BCrypt::Password.create string, cost: cost_value
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end
end
