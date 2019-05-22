class Client < ApplicationRecord
  # enum state: { active: 0, blocked: 1, deleted: 2 }
  STATES = %w(active blocked)
  CURRENCIES = %w(rub usd)
  WRITEOFF_TYPES = %w(prepaid postpaid)
  WRITEOFF_INTERVALS = [0, 1, 2, 3]
  BUSINESS_ENTITY_TYPES = %w(individual legal)

  # #############################################################
  # Associations

  has_many :roles, inverse_of: :client, dependent: :destroy
  has_many :invitations, dependent: :destroy


  # #############################################################
  # Validations

  validates :name,          presence: true
  validates :state,         presence: true, inclusion: { in: STATES } # validates :state, presence: true, inclusion: { in: states.keys }
  validates :currency,      presence: true, inclusion: { in: CURRENCIES }
  validates :writeoff_type, presence: true, inclusion: { in: WRITEOFF_TYPES }
  validates :writeoff_interval, presence: true, inclusion: { in: WRITEOFF_INTERVALS }
  validates :business_entity_type, presence: true, inclusion: { in: BUSINESS_ENTITY_TYPES }


  # #############################################################
  # Callbacks


  # #############################################################
  # Scopes

  scope :active, -> { where(deleted_at: nil) }

  # #############################################################
  # Class methods


  # #############################################################
  # Instance methods

  def block
    return false if self.state != 'active'
    self.update_attributes({
      state: 'blocked',
      blocked_at: Time.now,
    })
  end

  def unblock
    return false if self.state != 'blocked'
    self.update_attributes({
      state: 'active',
      blocked_at: nil,
    })
  end

  def delete
    # client.update_column(:state, 'deleted')
    # or more complex action do smth with products etc. ||
    # Client should remove all products before this action?
    # Client deleteion when Product is creating
    touch :deleted_at unless soft_deleted?
  end

  def soft_deleted?
    deleted_at.present?
  end

  protected

end
