class Image < ApplicationRecord
  include ResourcesStates

  CLOUD_STATUSES = %w(
    CREATED
  )

  CLOUD_TYPES = %w(
    Linux
    Windows
    Centos
    Other
  )

  # #############################################################
  # Associations

  belongs_to :location
  belongs_to :current_event, class_name: 'Event', required: false
  has_many :machines
  has_many :events, as: :resource


  # #############################################################
  # Validations

  validates :location,     presence: true
  validates :cloud_id,     presence: true
  validates :cloud_name,   presence: true
  validates :cloud_status, presence: true, inclusion: { in: CLOUD_STATUSES }
  validates :cloud_type,   presence: true#, inclusion: { in: CLOUD_TYPES }
  validates :state,        presence: true, inclusion: { in: STATES }


  # #############################################################
  # Callbacks


  # #############################################################
  # Scopes


  # #############################################################
  # Class methods

  def self.cloud_api(location)
    location = ::Location.find(location) if location.class == Integer
    CloudAPI::Image.new(location)
  end


  # #############################################################
  # Instance methods

  protected

end
