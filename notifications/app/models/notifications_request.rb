# frozen_string_literal: true

class NotificationsRequest < ApplicationRecord
  include DeliveryMethods
  DATA_KEYS = %w[
    phone_confirmation_code
    phone
    sms_token
    email_confirmation_code
    password_reset_code
    bonus_amount
    amount
    currency
    ticket_id
    period
    product_instance_id
    product_instance_name
    product_type_id
    product_type_name
    portal_instance_name
    invitation_token
    sender_name
    sender_email
    client_name
    role_name
    arenadb_phone
    arenadb_params
    locale
    name
    profession
    company
    tasks
    otherIaaS
    backup
    personalOfficeRating
    featuresHardFind
    mostNegativeImpression
    mostPositiveImpression
    whatNeedFix
    qualityServiceRating
    mostNegativeService
    mostPositiveService
    additionalFunctions
    client_id
    user_id
    cloud_response
    portal_id
    cloud_id
    cloud_name
    days_left
    recharge_balance_amount
  ].freeze

  has_many :notifications
  # templates_set?

  validates :content, presence: true, if: proc { |nr| nr.key_name.blank? }
  validates :delivery_method, inclusion: { in: delivery_methods.keys }, allow_nil: true, if: proc { |nr| nr.key_name.blank? }
  validate :provided_data_keys, if: proc { |nr| nr.provided_data.present? }
  validate :recipients
  # REVIEW: validate :content_integrity if: key_name.absent?

  after_create :internal_notification

  scope :processed, -> { where.not(processed_at: nil) }
  scope :unprocessed, -> { where(processed_at: nil) }

  def processed?
    processed_at.present?
  end

  def processed!
    touch :processed_at
  end

  def personalized?
    client_ids.present? || user_ids.present?
  end

  private

  # === Validations ===

  def provided_data_keys
    invalid_keys = provided_data.with_indifferent_access.keys.reject { |k| DATA_KEYS.include?(k) }
    errors.add(:provided_data, "invalid keys are: #{invalid_keys.join(', ')}. Valid keys are: #{DATA_KEYS.join(', ')}") if invalid_keys.present?
  end

  def recipients
    if [client_ids.presence, user_ids.presence, emails.presence, phones.presence].compact.length != 1
      errors.add(:base, 'Recipients can\'t be blank or one recipient type can present at a time')
    end
  end

  def internal_notification
    InternalMailer.arena_db(self).deliver_later if key_name == 'arena_db_order' && Rails.application.secrets.arena_db_emails.present?
  end
end
