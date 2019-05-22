class Role < ApplicationRecord

  # #############################################################
  # Associations

  belongs_to :client,    inverse_of: :roles
  has_many :profiles,    inverse_of: :role
  has_many :users,       inverse_of: :role, through: :profiles
  has_many :invitations, dependent: :destroy


  # #############################################################
  # Validations

  validates :client,   presence: true
  validates :name,     presence: true


  # #############################################################
  # Callbacks


  # #############################################################
  # Scopes


  # #############################################################
  # Class methods

  def self.create_admin_role(client)
    Role.create!({
      client: client,
      name: 'Admin',
      read_only: true,
      permissions: {},
    })
  end


  # #############################################################
  # Instance methods


  protected

end
