class User < ApplicationRecord
  has_secure_password
  attr_accessor :remember_token, :activation_token, :reset_token

  has_many :microposts, dependent: :destroy
  has_many :active_relationships,   class_name:   Relationship.name,
                                     foreign_key:  "follower_id",
                                     dependent:    :destroy
  has_many :passive_relationships,  class_name:   Relationship.name,
                                     foreign_key:  "followed_id",
                                     dependent:    :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  validates :password,
            presence: true,
            length: {minimum: Settings.digits.length_6},
            allow_nil: true

  validates :email,
            presence: true,
            uniqueness: true,
            length: {maximum: Settings.digits.length_50},
            format: {with: Settings.regex_valid.email}
  validates :name, presence: true
  validate :birthday_within_last_100_years

  before_save :downcase_email
  before_create :create_activation_digest

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def session_token
    remember_digest || remember
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def feed
    Micropost.feed(id)
  end

  def follow other_user
    following << other_user unless self == other_user
  end

  def unfollow other_user
    following.delete other_user
  end

  def following? other_user
    following.include?(other_user)
  end

  private

  def birthday_within_last_100_years
    return unless birthday.present? && birthday < 100.years.ago.to_date

    errors.add :birthday, I18n.t("must_be_within_the_last_100_years")
  end

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
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
