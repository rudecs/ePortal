class Profile < ApplicationRecord

  # #############################################################
  # Associations

  belongs_to :role, inverse_of: :profiles
  belongs_to :user, inverse_of: :profiles


  # #############################################################
  # Validations

  validates :role,    presence: true,
                      uniqueness: {scope: :user} # https://github.com/thoughtbot/shoulda-matchers/issues/814
  validates :user,    presence: true


  # #############################################################
  # Callbacks

  around_destroy :destroy_orphaned_client

  # #############################################################
  # Scopes


  # #############################################################
  # Class methods


  # #############################################################
  # Instance methods


  protected

  # not sure if it is a good idea.
  # TODO: check consequences
  def destroy_orphaned_client
    client = role.client
    yield
    if client.present? && Role.where(client_id: client.id).joins(:profiles).none?
      client.delete
    end
  end
end
