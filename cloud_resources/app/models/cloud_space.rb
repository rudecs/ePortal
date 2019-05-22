class CloudSpace < ApplicationRecord
  include ResourcesStates

  CLOUD_STATUSES = %w(
    DEPLOYED
    DEPLOYING
    DELETED
    DELETING
    DESTROYED
    DESTROYING
    DISABLED
    DISABLING
    VIRTUAL
  )


  # #############################################################
  # Associations

  belongs_to :location
  belongs_to :current_event, class_name: 'Event', required: false
  has_many :events, as: :resource
  has_many :machines
  has_many :ports


  # #############################################################
  # Validations

  validates :location, presence: true
  # validates :cloud_id, presence: true
  validates :cloud_name, presence: true
  validates :cloud_status, allow_nil: true, inclusion: { in: CLOUD_STATUSES }
  validates :state, presence: true, inclusion: { in: STATES }


  # #############################################################
  # Callbacks


  # #############################################################
  # Scopes


  # #############################################################
  # Class methods

  def self.cloud_api(location)
    location = ::Location.find(location) if location.class == Integer
    CloudAPI::CloudSpace.new(location)
  end

  def self.create!(params)
    event_started_at = Time.now
    cloud_space = nil
    ActiveRecord::Base.transaction do
      params = params.symbolize_keys
      params[:id] = ::ResourceIdSequence.nextval unless params[:id].present?
      params[:state] = 'processing'
      params[:cloud_name] = params[:id].to_s
      self.new(params).validate!

      cloud_space_struct = self.cloud_api(params[:location_id]).create(params[:cloud_name])
      params[:state] = 'active' if cloud_space_struct.status == 'DEPLOYED'
      params[:state] = 'processing' if cloud_space_struct.status == 'DEPLOYING'
      params[:cloud_id] = cloud_space_struct.id
      params[:cloud_public_ip_address] = cloud_space_struct.publicipaddress
      params[:cloud_status] = cloud_space_struct.status
      cloud_space = super
      cloud_space.save!
    end

    create_event_params = {
      resource: cloud_space,
      name: 'create',
      started_at: event_started_at,
    }
    create_event_params[:finished_at] = Time.now if cloud_space.state != 'processing'
    event = ::Event.create(create_event_params)
    cloud_space.current_event_id = event.id
    cloud_space.save
    cloud_space
  end


  # #############################################################
  # Instance methods

  def cloud_api
    CloudAPI::CloudSpace.new(self.location)
  end

  def delete
    event_started_at = Time.now
    result = self.cloud_api.delete(self.cloud_id)
    return false if result != true
    self.update_attributes({
      state: 'deleted',
      deleted_at: Time.now,
      current_event_id: nil,
    })

    event = ::Event.create({
      resource: self,
      name: 'delete',
      started_at: event_started_at,
      finished_at: Time.now,
    })

    self
  end

  def fetch
    self.cloud_api.find(self.cloud_id)
    rescue RuntimeError => e
      if e.message == "404 \"Could not find an accessible resource.\""
        struct = Struct.new(*CloudAPI::CloudSpace::STRUCT_FIELDS).new
        struct.status = 'DELETED'
        return struct
      end
      raise e
  end

  def process
    self.refresh
    if self.state == 'processing'
      sleep(1)
      self.process
    else
      self
    end
  end

  def refresh
    cloud_space_struct = self.fetch
    old_state = self.state
    self.state = 'active' if cloud_space_struct.status == 'DEPLOYED'
    self.state = 'processing' if cloud_space_struct.status == 'DEPLOYING'
    self.state = 'deleted' if cloud_space_struct.status == 'DELETED'
    self.cloud_status = cloud_space_struct.status
    self.cloud_public_ip_address = cloud_space_struct.publicipaddress
    self.save!

    if old_state != self.state
      event = self.current_event
      if event.present? && event.finished_at.nil?
        event.update_attributes({
          finished_at: Time.at(cloud_space_struct.updateTime)
        })
      end
    end

    self
  end

  protected

end
