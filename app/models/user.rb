class User < ApplicationRecord
  before_save :downcase_email

  has_secure_password

  validates :email,
            presence: true,
            length: {maximum: Settings.digits.length_50},
            format: {with: Settings.regex_valid.email}
  validates :name, presence: true
  validate :birthday_within_last_100_years

  private

  def birthday_within_last_100_years
    return unless birthday.present? && birthday < 100.years.ago.to_date

    errors.add :birthday, I18n.t("must_be_within_the_last_100_years")
  end

  def downcase_email
    email.downcase!
  end
end
