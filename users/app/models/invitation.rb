# frozen_string_literal: true

class Invitation < ApplicationRecord
  include EmailRegex

  enum state: { pending: 0, accepted: 1, rejected: 2 }
  EXPIRATION_PERIOD = 2.weeks # TODO: set on deploy

  belongs_to :client
  belongs_to :role
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User', optional: true

  before_validation :assign_receiver, on: :create
  before_validation :generate_token, on: :create
  after_commit :send_invitation

  validates :sender, :client, presence: true
  validates :email, presence: true,
                    format: { with: email_regex },
                    uniqueness: { scope: :client } # handles already invited
  validates :token, presence: true, uniqueness: true
  validates :role, presence: true
  validate :self_sent?
  validate :role_in_client, on: :create
  validate :already_in_client, on: :create
  # validate sender role in client
  # count limit?

  scope :external, -> { where(receiver_id: nil) }
  scope :internal, -> { where.not(receiver_id: nil) }
  scope :actual,   -> { where('expired_at > ?', Time.now) }
  scope :expired,  -> { where('expired_at <= ?', Time.now) }

  # cancel invitation. delete?
  def initialize(*args, &block)
    @send_invitation = false
    super
  end

  class << self
    def handle_create_request(attributes = {})
      inv = find_or_initialize_by attributes.except(:role_id)
      inv.role_id = attributes[:role_id]

      if inv.persisted?
        if inv.accepted?
          return inv if inv.already_in_client
          # Reinvite kinda action. If accepted user left client.
          inv.state = 'pending'
          inv.generate_token
        elsif inv.rejected?
          # recevier should be defined or inv.assign_receiver
          inv.state = 'pending'
          inv.generate_token
        end
        inv.role_in_client
        inv.assign_receiver if inv.pending? && inv.receiver.blank?
        # @send_invitation = true if some time depending on expir?
        inv.generate_token if inv.expired?
      end

      inv.save
      inv
    end
  end

  def email=(value)
    super value.try(:downcase)
  end

  def send_invitation
    return unless @send_invitation
    params = {
      provided_data: {
        # TODO: decorator sender.decorate.name
        sender_name: sender.first_name.present? || sender.last_name.present? ? [sender.first_name&.upcase_first, sender.last_name&.upcase_first].join(' ') : sender.email,
        sender_email: sender.email,
        client_name: client.name,
        role_name: role.name
      },
    }
    if receiver.present?
      params.merge!(
        key_name: Notification::Template::KEY_INVITATION_WITH_RECEIVER,
        user_ids: [receiver_id]
      )
    else
      params.deep_merge!(
        key_name: Notification::Template::KEY_INVITATION,
        emails: [email],
        provided_data: { invitation_token: token }
      )
    end

    if Rails.env.development?
      puts '================================'
      puts 'Invitation#send_to_notifications'
      puts JSON.pretty_generate(params)
      puts '================================'
      return
    end

    Notification::Template.send(params)
    # if receiver.present?
    #   Notification::Template.send(params)
    # else
    #   InvitationMailer.invite(self, sender).deliver_now # TODO: background job
    # end
  end

  def accepted!
    # pending => accepted? any => accepted?
    if !pending?
      errors.add(:state, :invalid_transition)
      return false
    end

    if receiver.blank?
      errors.add(:receiver, :invalid)
      return false
    end

    ActiveRecord::Base.transaction do
      # REVIEW: new user case;
      # already belongs to client case(resolved by receiver !== sender, receiver)?
      # change email use-case?! when invited receiver = nil.

      # order matters!
      super
      Profile.create!(role_id: role_id, user_id: receiver_id)
    end
  rescue
    false
  end

  # what to do with rejected invites? destroy? can be reinvited?
  def rejected!
    # pending => rejected
    if !pending?
      errors.add(:state, :invalid_transition)
      return false
    end

    super
  end

  def pending!
    unless state.nil? || pending?
      errors.add(:state, :invalid_transition)
      return false
    end

    super
  end

  def role_in_client
    if client.present? && role.present?
      errors.add(:role, :role_in_client) unless client.roles.where(id: role.id).present?
    end
  end

  def expired?
    Time.now >= expired_at
  end

  def generate_token
    self.token = SecureRandom.hex(32)
    self.expired_at = EXPIRATION_PERIOD.from_now
    @send_invitation = true
  end

  def assign_receiver
    self.receiver = User.find_by_email(email) if email.present? # assigns nil or user
  end

  def already_in_client
    if receiver.present? && client.present?
      errors.add(:receiver, :already_in_client) if User.joins(profiles: :role).where(id: receiver_id, profiles: { roles: { client_id: client_id }}).present?
    end
  end

  private

  def self_sent?
    errors.add(:receiver, :invalid) if receiver.present? && sender.present? && receiver.id == sender.id
  end
end
