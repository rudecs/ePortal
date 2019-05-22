class Port < ApplicationRecord
  include ResourcesStates

  PROTOCOLS = %w(tcp udp)

  # #############################################################
  # Associations

  belongs_to :cloud_space
  belongs_to :machine


  # #############################################################
  # Validations

  validates :cloud_space, presence: true
  validates :machine, presence: true
  validates :state, presence: true, inclusion: { in: STATES }
  validates :cloud_protocol, presence: true, inclusion: { in: PROTOCOLS }
  validates :cloud_local_ip, presence: true
  validates :cloud_local_port, presence: true
  validates :cloud_public_ip, presence: true
  validates :cloud_public_port, presence: true


  # #############################################################
  # Callbacks


  # #############################################################
  # Scopes


  # #############################################################
  # Class methods

  def self.cloud_api(location)
    location = ::Location.find(location) if location.class == Integer
    CloudAPI::Port.new(location)
  end

  def self.create!(params)
    event_started_at = Time.now
    port = nil
    ActiveRecord::Base.transaction do
      params = params.symbolize_keys
      params[:id] = ::ResourceIdSequence.nextval unless params[:id].present?
      params[:state] = 'processing'

      cloud_space = ::CloudSpace.find(params[:cloud_space_id])
      machine = ::Machine.find(params[:machine_id])

      params[:cloud_local_ip] = machine.local_ip_address
      params[:cloud_public_ip] = cloud_space.cloud_public_ip_address

      self.new(params).validate!

      location = cloud_space.location
      port_struct = self.cloud_api(location).create({
        cloudspaceId: cloud_space.cloud_id,
        machineId: machine.cloud_id,
        publicIp: params[:cloud_public_ip],
        publicPort: params[:cloud_public_port],
        localPort: params[:cloud_local_port],
        protocol: params[:cloud_protocol],
      })

      params[:cloud_id] = port_struct.id
      params[:state] = 'active'
      port = super
    end

    event = ::Event.create({
      resource: port,
      name: 'create',
      started_at: event_started_at,
      finished_at: Time.now,
    })

    port
  end


  # #############################################################
  # Instance methods

  def cloud_api
    location = self.cloud_space.location
    CloudAPI::Port.new(location)
  end

  def delete
    event_started_at = Time.now
    begin
      result = self.cloud_api.delete({
        cloudspaceId: self.cloud_space.cloud_id,
        publicIp: self.cloud_public_ip,
        publicPort: self.cloud_public_port,
        proto: self.cloud_protocol,
      })
    rescue RuntimeError => err
      raise err unless err.message.include? "404 \"Could not find"
    else
      return false if result != true
    end
    self.update_attributes({
      state: 'deleted',
      deleted_at: Time.now,
    })

    event = ::Event.create({
      resource: self,
      name: 'delete',
      started_at: event_started_at,
      finished_at: Time.now,
    })

    self
  end

  def update(params)
    ActiveRecord::Base.transaction do
      raise self.errors unless super

      self.cloud_api.update({
        id: self.cloud_id,
        cloudspaceId: self.cloud_space.cloud_id,
        machineId: self.machine.cloud_id,
        publicIp: self.cloud_space.cloud_public_ip_address,
        publicPort: params[:cloud_public_port] || self.cloud_public_port,
        localPort: params[:cloud_local_port] || self.cloud_local_port,
        protocol: params[:cloud_protocol] || self.cloud_protocol,
      })
    end
    self
  end


  protected


end
