class Machine < ApplicationRecord
  include ResourcesStates

  CLOUD_STATUSES = %w(
    RUNNING
    HALTED
    PAUSED
    DELETED
  )

  ACTIVE_CLOUD_STATUSES = %w(
    RUNNING
    HALTED
    PAUSED
  )

  # #############################################################
  # Associations

  belongs_to :cloud_space
  belongs_to :image
  belongs_to :current_event, class_name: 'Event', required: false
  has_many :events, as: :resource
  has_many :snapshots
  has_many :disks
  has_many :ports


  # #############################################################
  # Validations

  validates :cloud_space, presence: true
  validates :image, presence: true
  validates :state, presence: true, inclusion: { in: STATES }
  validates :status, allow_nil: true, inclusion: { in: CLOUD_STATUSES }
  validates :memory, presence: true
  validates :vcpus, presence: true
  validates :boot_disk_size, presence: true


  # #############################################################
  # Callbacks


  # #############################################################
  # Scopes


  # #############################################################
  # Class methods

  def self.cloud_api(location)
    location = ::Location.find(location) if location.class == Integer
    CloudAPI::Machine.new(location)
  end

  def self.create!(params)
    event_started_at = Time.now
    ActiveRecord::Base.transaction do
      params = params.symbolize_keys
      params[:id] = ::ResourceIdSequence.nextval unless params[:id].present?
      params[:state] = 'processing'
      self.new(params).validate!

      cloud_space = ::CloudSpace.find(params[:cloud_space_id])
      location = cloud_space.location
      image = ::Image.find(params[:image_id])

      machine_struct = self.cloud_api(location).create({
        cloudspaceId: cloud_space.cloud_id,
        imageId: image.cloud_id,
        name: params[:id],
        memory: params[:memory],
        vcpus: params[:vcpus],
        disksize: params[:boot_disk_size],
        ssh_keys: params[:ssh_keys],
      })

      if ACTIVE_CLOUD_STATUSES.include? machine_struct.status
        params[:state] = 'active'
      else
        params[:state] = 'processing'
      end

      params[:cloud_id] = machine_struct.id
      params[:local_ip_address] = machine_struct.interfaces.first['ipAddress']
      params[:status] = machine_struct.status
      machine = super

      create_event_params = {
        resource: machine,
        name: 'create',
        started_at: event_started_at,
      }
      create_event_params[:finished_at] = Time.now if machine.state != 'processing'
      event = ::Event.create(create_event_params)

      machine.current_event_id = event.id
      machine.save!

      machine_struct.disks.map do |disk|
        ::Disk.parse_exist!({
          machine_id: machine.id,
          partner_id: machine.partner_id,
          client_id: machine.client_id,
          product_id: machine.product_id,
          product_instance_id: machine.product_instance_id,
          cloud_id: disk['id'],
        })
      end

      machine
    end
  end



  # #############################################################
  # Instance methods

  def boot_disk
    self.disks.find_by(cloud_type: 'B')
  end

  def cloud_api
    location = self.cloud_space.location
    CloudAPI::Machine.new(location)
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

    self.snapshots.where(state: 'active').find_each do |snapshot|
      snapshot.delete
    end

    self.disks.where(state: 'active').find_each do |disk|
      struct = disk.fetch
      if struct.status == 'DELETED'
        disk.update_attributes({
          state: 'deleted',
          deleted_at: Time.now,
          current_event_id: nil,
        })
        ::Event.create({
          resource: disk,
          name: 'delete',
          started_at: event_started_at,
          finished_at: Time.now,
        })
      end
    end

    self.ports.where(state: 'active').find_each do |port|
      port.update_attributes({
        state: 'deleted',
        deleted_at: Time.now,
      })
      ::Event.create({
        resource: port,
        name: 'delete',
        started_at: event_started_at,
        finished_at: Time.now,
      })
    end


    self
  end

  def fetch
    self.cloud_api.find(self.cloud_id)
    rescue RuntimeError => e
      if e.message.include?('404')
        struct = Struct.new(*CloudAPI::Machine::STRUCT_FIELDS).new
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
    machine_struct = self.fetch
    old_state = self.state
    old_memory = self.memory
    old_vcpus = self.vcpus
    self.state = 'active' if ACTIVE_CLOUD_STATUSES.include? machine_struct.status
    self.state = 'deleted' if machine_struct.status == 'DELETED'
    self.status = machine_struct.status if machine_struct.status.present?
    self.local_ip_address = machine_struct.interfaces.first['ipAddress'] if machine_struct.interfaces.present?
    self.memory = machine_struct.memory if machine_struct.memory.present?
    self.vcpus = machine_struct.vcpus if machine_struct.vcpus.present?
    self.save!

    if old_state != self.state || old_memory != self.memory || old_vcpus != self.vcpus
      event = self.current_event
      if event.present? && event.finished_at.nil?
        event.update_attributes({
          finished_at: Time.now,
        })
      end
    end

    self
  end

  def reset
    self.cloud_api.stop(self.cloud_id)
    self.cloud_api.start(self.cloud_id)
    self.refresh
  end

  def resize(memory:, vcpus:)
    event = ::Event.create({
      resource: self,
      name: 'resize',
      started_at: Time.now,
    })

    self.update_attributes({
      current_event_id: event.id,
    })

    self.cloud_api.resize({
      id: self.cloud_id,
      memory: memory,
      vcpus: vcpus,
    })

    self.refresh
  end

  def start
    event_started_at = Time.now
    self.cloud_api.start(self.cloud_id)
    self.refresh
    event = ::Event.create({
      resource: self,
      name: 'start',
      started_at: event_started_at,
      finished_at: Time.now,
    })
  end

  def stop
    event_started_at = Time.now
    self.cloud_api.stop(self.cloud_id)
    self.refresh
    event = ::Event.create({
      resource: self,
      name: 'stop',
      started_at: event_started_at,
      finished_at: Time.now,
    })
  end

  def pause
    self.cloud_api.pause(self.cloud_id)
    self.refresh
  end

  def get_console_url
    self.cloud_api.get_console_url(self.cloud_id)
  end

  protected

end
