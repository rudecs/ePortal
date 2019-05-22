class User < ApplicationRecord
  include EmailRegex

  STATES = %w(active)

  has_secure_password

  # #############################################################
  # Associations

  has_many :sessions, inverse_of: :user, dependent: :destroy
  has_many :roles,    inverse_of: :user, through: :profiles


  # #############################################################
  # Validations

  validates :state, presence: true, inclusion: { in: STATES }
  validates :email, format: { with: email_regex },
                    uniqueness: { case_sensitive: false },
                    allow_blank: true
  validates :phone, uniqueness: true,
                    phony_plausible: true,
                    allow_blank: true

  # #############################################################
  # Callbacks

  before_validation :generate_email_confirmation_code, on: :create
  before_update :clear_reset_password_token, if: :clear_reset_password_token?

  before_create :generate_phone_confirmation_code, if: :send_phone_confirmation_notification?
  after_create :skip_phone_reconfirmation_in_callback!, if: :send_phone_confirmation_notification?
  after_commit :send_phone_confirmation_instructions, on: :create, if: :send_phone_confirmation_notification?
  after_commit :send_phone_reconfirmation_instructions, on: :update, if: :phone_reconfirmation_required?
  before_update :postpone_phone_change_until_confirmation_and_regenerate_confirmation_code, if: :postpone_phone_change?

  after_commit :send_email_confirmation_code, on: :create


  # #############################################################
  # Scopes


  # #############################################################
  # Class methods

  def initialize(*args, &block)
    @phone_reconfirmation_required = false
    @bypass_phone_confirmation_postpone = false
    @skip_phone_reconfirmation_in_callback = false
    @raw_phone_confirmation_code = nil
    @raw_disable_2fa_confirmation_code = nil
    super
  end

  class << self
    def digest(string)
      OpenSSL::HMAC.hexdigest('SHA256', 'users password_reset_code', string)
    end

    def reset_password_by_code(attributes={})
      original_code = attributes[:password_reset_code]
      password_reset_code  = User.digest(original_code)

      user = find_or_initialize_by(password_reset_code: password_reset_code)

      if user.persisted?
        if user.password_reset_code_expired_at && user.password_reset_code_expired_at <= Time.now
          user.errors.add(:password_reset_code, :expired)
        else
          user.reset_password(attributes[:password], attributes[:password_confirmation])
        end
      else
        user.errors.add(:password_reset_code, :invalid)
      end

      user.password_reset_code = original_code if user.password_reset_code.present? # wtf?
      user
    end
  end

  # #############################################################
  # Instance methods

  def confirm_email(confirmation_code)
    if self.email_confirmation_code == confirmation_code && Time.now < self.email_confirmation_code_expired_at
      self.update_attributes({
        email_confirmed_at: Time.now,
      })
    end
  end

  def generate_email_confirmation_code
    return unless self.email.present? && self.email_confirmed_at.nil?
    self.email_confirmation_code_expired_at = Time.now + 24.hours
    self.email_confirmation_code = SecureRandom.hex(32)
  end

  def send_email_confirmation_code
    return unless self.email_confirmation_code.present?
    Notification::Template.send({
      key_name: Notification::Template::KEY_EMAIL_CONFIRMATION,
      user_ids: [self.id],
      provided_data: {
        email_confirmation_code: self.email_confirmation_code,
      },
    })
  end

  def send_phone_confirmation_code(code)
    Notification::Template.send({
      key_name: Notification::Template::KEY_PHONE_CONFIRMATION,
      user_ids: [self.id],
      provided_data: {
        phone_confirmation_code: code,
        phone: self.unconfirmed_phone
      },
    })
  end

  def create_password_reset_code
    return false unless self.email.present?
    raw = SecureRandom.urlsafe_base64(32)
    enc = User.digest(raw)
    self.password_reset_code = enc
    self.password_reset_code_expired_at = Time.now + 1.hour
    save(validate: false)
    raw
  end

  def send_password_reset_email(raw_code)
    Notification::Template.send({
      key_name: Notification::Template::KEY_PASSWORD_RESET,
      user_ids: [self.id],
      provided_data: {
        password_reset_code: raw_code,
      },
    })
  end

  def reset_password(new_password, new_password_confirmation)
    if new_password.present?
      self.password = new_password
      self.password_confirmation = new_password_confirmation
      save
    else
      errors.add(:password, :blank)
      false
    end
  end

  def clear_reset_password_token?
    respond_to?(:will_save_change_to_password_digest?) && will_save_change_to_password_digest?
  end

  def clear_reset_password_token
    self.password_reset_code = nil
    self.password_reset_code_expired_at = nil
  end

  # === Phone confirmation ===
  # TODO: refactor methods, move to phone confirmation concern
  def confirm_phone
    pending_any_phone_confirmation do
      if phone_confirmation_period_expired?
        self.errors.add(:phone, :confirmation_period_expired)
        return false
      end

      self.phone_confirmed_at = Time.now # .utc
      if pending_phone_reconfirmation?
        skip_phone_reconfirmation! # TODO: phone will be changed
        self.phone = unconfirmed_phone
        self.unconfirmed_phone = nil
      end
      save(validate: true)
    end
  end

  def generate_phone_confirmation_code
    if self.phone_confirmation_code && !phone_confirmation_period_expired?
      @raw_phone_confirmation_code = self.phone_confirmation_code
    else
      self.phone_confirmation_code = @raw_phone_confirmation_code = (SecureRandom.random_number(9e7) + 1e7).to_i
      self.phone_confirmation_code_expired_at = Time.now + 10.minutes
    end
  end

  def generate_phone_confirmation_code!
    generate_phone_confirmation_code && save(validate: false)
  end

  def phone_confirmation_period_expired?
    self.phone_confirmation_code_expired_at.present? && Time.now > self.phone_confirmation_code_expired_at
  end

  def skip_phone_reconfirmation!
    @bypass_phone_confirmation_postpone = true
  end

  def skip_phone_reconfirmation_in_callback!
    @skip_reconfirmation_in_callback = true
  end

  def send_phone_confirmation_notification?
    !phone_confirmed? && self.phone.present?
  end

  def phone_reconfirmation_required?
    @phone_reconfirmation_required && (self.phone.present? || self.unconfirmed_phone.present?)
  end

  def phone_confirmed?
    phone_confirmed_at.present? # !!phone_confirmed_at
  end

  def pending_phone_reconfirmation?
    unconfirmed_phone.present?
  end

  def send_phone_confirmation_instructions
    unless @raw_phone_confirmation_code
      generate_phone_confirmation_code!
    end

    # opts = pending_phone_reconfirmation? ? { to: unconfirmed_phone } : {}
    send_phone_confirmation_code(@raw_phone_confirmation_code)
  end

  def send_phone_reconfirmation_instructions
    @phone_reconfirmation_required = false
    send_phone_confirmation_instructions
  end

  def resend_phone_confirmation_instructions
    pending_any_phone_confirmation do
      send_phone_confirmation_instructions
    end
  end

  def pending_any_phone_confirmation
    if (!phone_confirmed? || pending_phone_reconfirmation?)
      yield
    else
      self.errors.add(:phone, :already_confirmed)
      false
    end
  end

  def postpone_phone_change?
    postpone = will_save_change_to_phone? &&
      !@bypass_phone_confirmation_postpone &&
      self.phone.present? &&
      (!@skip_phone_reconfirmation_in_callback || self.phone_in_database.present?)
    @bypass_phone_confirmation_postpone = false
    postpone
  end

  def postpone_phone_change_until_confirmation_and_regenerate_confirmation_code
    self.unconfirmed_phone = self.phone
    self.phone = self.phone_in_database
    return unless will_save_change_to_unconfirmed_phone?
    @phone_reconfirmation_required = true
    self.phone_confirmation_code = nil
    generate_phone_confirmation_code
  end

  def generate_disable_2fa_confirmation_code
    if self.disable_2fa_confirmation_code && !disable_2fa_period_expired?
      @raw_disable_2fa_confirmation_code = self.disable_2fa_confirmation_code
    else
      self.disable_2fa_confirmation_code = @raw_disable_2fa_confirmation_code = (SecureRandom.random_number(9e7) + 1e7).to_i
      self.disable_2fa_confirmation_code_expired_at = Time.now + 10.minutes
    end
  end

  def send_disable_2fa_confirmation_code
    Notification::Template.send({
      key_name: Notification::Template::KEY_PHONE_CONFIRMATION,
      user_ids: [self.id],
      provided_data: {
        phone_confirmation_code: self.disable_2fa_confirmation_code,
        phone: self.phone
      },
    })
  end

  def disable_2fa_period_expired?
    self.disable_2fa_confirmation_code_expired_at.present? && Time.now > self.disable_2fa_confirmation_code_expired_at
  end

  def disable_2fa(confirmation_code)
    if self.disable_2fa_confirmation_code != confirmation_code
      self.errors.add(:disable_2fa, :wrong_disable_2fa_confirmation_code)
    end

    if Time.now >= self.disable_2fa_confirmation_code_expired_at
      self.errors.add(:disable_2fa, :confirmation_period_expired)
    end

    self.disable_2fa_confirmation_code = nil
    self.disable_2fa_confirmation_code_expired_at = nil
    self.is_enabled_2fa = false
    self.save
  end

  protected

end
