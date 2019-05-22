class Session < ApplicationRecord

  has_secure_token

  # #############################################################
  # Associations

  belongs_to :user, inverse_of: :sessions


  # #############################################################
  # Validations

  validates :user,  presence: true
  validates :expired_at,  presence: true
  validates :token, presence: true, uniqueness: true


  # #############################################################
  # Callbacks

  before_validation :generate_token, on: :create
  before_validation :generate_sms_token, on: :create
  before_validation :set_expiration_date


  # #############################################################
  # Scopes


  # #############################################################
  # Class methods


  # #############################################################
  # Instance methods


  protected

  def generate_token
    self.token = SecureRandom.base58(24)
  end

  def generate_sms_token
    return unless self.user.is_enabled_2fa
    self.sms_token_expired_at = Time.now + 5.minutes
    self.sms_token = (SecureRandom.random_number(9e5) + 1e5).to_i
    Notification::Template.send({
      key_name: Notification::Template::KEY_TWO_FACTOR_AUTHENTICATION,
      user_ids: [self.user.id],
      provided_data: {
        sms_token: self.sms_token,
      },
    })
  end

  def set_expiration_date
    self.expired_at = Time.now + 14.days
  end

end
