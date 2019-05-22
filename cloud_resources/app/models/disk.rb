class Disk < ApplicationRecord
  include ResourcesStates

  self.inheritance_column = nil

  TYPES = %w(
    archive
    standard
    custom
  )

  CLOUD_TYPES = %w(
    B D
  )

  ARCHIVE_MAX_BYTES_SEC = 80 * 1024 * 1024
  ARCHIVE_MAX_IOPS = 120
  ARCHIVE_MIN_BYTES_SEC = 120 * 1024 * 1024
  ARCHIVE_MIN_IOPS = 40
  ARCHIVE_IOGB_RATIO = 1

  STANDARD_MAX_BYTES_SEC = 120 * 1024 * 1024
  STANDARD_MAX_IOPS = 3000
  STANDARD_MIN_BYTES_SEC = 120 * 1024 * 1024
  STANDARD_MIN_IOPS = 300
  STANDARD_IOGB_RATIO = 3

  CUSTOM_MAX_BYTES_SEC = 240 * 1024 * 1024
  CUSTOM_MAX_IOPS = 10000
  CUSTOM_MIN_BYTES_SEC = 240 * 1024 * 1024
  CUSTOM_MIN_IOPS = 1000
  CUSTOM_IOGB_RATIO = 100

  # #############################################################
  # Associations

  belongs_to :machine, required: false


  # #############################################################
  # Validations

  # validates :machine, presence: true
  validates :state, presence: true, inclusion: { in: STATES }
  # validates :status, allow_nil: true, inclusion: { in: CLOUD_STATUSES }
  validates :cloud_type, allow_nil: false, inclusion: { in: CLOUD_TYPES }
  # validates :cloud_type, allow_nil: false, inclusion: { in: ['D'] }
  # validates :type, allow_nil: false, inclusion: { in: TYPES }
  validates :size, presence: true
  validates :iops_sec, presence: true
  validates :bytes_sec, presence: true



  # #############################################################
  # Callbacks


  # #############################################################
  # Scopes
  scope :boot_type, -> { where(cloud_type: 'B') }
  scope :data_type, -> { where(cloud_type: 'D') }


  # #############################################################
  # Class methods

  def self.calc_iops_sec(type, size, iops_sec=nil)
    size = size.to_i
    if type == 'archive'
      min_size = 200
      iops = [( 40 + 80*(size - min_size)/(1000 - min_size) ).round, ARCHIVE_MAX_IOPS].min
    elsif type == 'standard'
      iops = size * STANDARD_IOGB_RATIO
      iops = STANDARD_MIN_IOPS if iops < STANDARD_MIN_IOPS
      iops = STANDARD_MAX_IOPS if iops > STANDARD_MAX_IOPS
    elsif type == 'custom'
      iops = [CUSTOM_MAX_IOPS, [CUSTOM_MIN_IOPS, size * CUSTOM_IOGB_RATIO].max].min
      iops = iops_sec if iops_sec < iops && iops_sec > CUSTOM_MIN_IOPS if iops_sec.present?
    end
    # fix: минимальное кол-во iops в новой версии облака
    iops = 80 if iops < 80
    iops
  end

  def self.calc_bytes_sec(type, size)
    bytes_sec = size * 1024 * 1024
    if type == 'archive'
      minMBps = 40 * 1024 * 1024
      maxMBps = 120 * 1024 * 1024
      optimalSize = 1000
      minSize = 200
      bytes_sec = [(minMBps+(maxMBps-minMBps)*(size-minSize)/(optimalSize-minSize)).floor, maxMBps].min
    elsif type == 'standard'
      bytes_sec = STANDARD_MAX_BYTES_SEC if bytes_sec > STANDARD_MAX_BYTES_SEC
    elsif type == 'custom'
      bytes_sec = CUSTOM_MAX_BYTES_SEC if bytes_sec > CUSTOM_MAX_BYTES_SEC
    end

    bytes_sec
  end

  def self.cloud_api(location)
    location = ::Location.find(location) if location.class == Integer
    CloudAPI::Disk.new(location)
  end

  def self.create!(params)
    event_started_at = Time.now
    disk = nil
    ActiveRecord::Base.transaction do
      params = params.symbolize_keys
      params[:id] = ::ResourceIdSequence.nextval unless params[:id].present?
      params[:cloud_type] = 'D'
      params[:iops_sec] = ::Disk.calc_iops_sec(params[:type], params[:size], params[:iops_sec])
      params[:bytes_sec] = ::Disk.calc_bytes_sec(params[:type], params[:size])
      params[:state] = 'active'
      self.new(params).validate!

      machine = ::Machine.find(params[:machine_id])
      location = machine.cloud_space.location
      cloud_api = ::Disk.cloud_api(location)
      disk_struct = cloud_api.create({
        name: params[:id],
        size: params[:size],
        type: params[:cloud_type],
        iops: params[:iops_sec],
      })

      machine.cloud_api.attach_disk({
        machine_id: machine.cloud_id,
        disk_id: disk_struct.id,
      })

      cloud_api.limit_io({
        id: disk_struct.id,
        iops_sec: params[:iops_sec],
        bytes_sec: params[:bytes_sec],
      })

      params[:cloud_id] = disk_struct.id
      params[:cloud_status] = disk_struct.status

      disk = super

    end
    event = ::Event.create({
      resource: disk,
      name: 'create',
      started_at: event_started_at,
      finished_at: Time.now,
    })

    disk
  end

  def self.parse_exist!(params)
    event_started_at = Time.now
    disk = nil
    ActiveRecord::Base.transaction do
      params = params.symbolize_keys

      machine = ::Machine.find(params[:machine_id])
      location = machine.cloud_space.location
      cloud_api = ::Disk.cloud_api(location)
      disk_struct = cloud_api.find(params[:cloud_id])
      return false unless CLOUD_TYPES.include?(disk_struct.type)

      params[:id] = ::ResourceIdSequence.nextval unless params[:id].present?
      params[:size] = disk_struct.sizeMax
      params[:cloud_id] = disk_struct.id
      params[:cloud_status] = disk_struct.status
      params[:cloud_type] = disk_struct.type
      params[:type] = 'standard' unless params[:type].present?
      params[:iops_sec] = ::Disk.calc_iops_sec(params[:type], params[:size])
      params[:bytes_sec] = ::Disk.calc_bytes_sec(params[:type], params[:size])
      params[:state] = 'active'
      self.new(params).validate!

      machine.cloud_api.attach_disk({
        machine_id: machine.cloud_id,
        disk_id: disk_struct.id,
      })

      cloud_api.limit_io({
        id: disk_struct.id,
        iops_sec: params[:iops_sec],
        bytes_sec: params[:bytes_sec],
      })


      disk = self.new(params)
      disk.save!
    end

    event = ::Event.create({
      resource: disk,
      name: 'create',
      started_at: event_started_at,
      finished_at: Time.now,
    })

    disk
  end


  # #############################################################
  # Instance methods

  def cloud_api
    location = self.machine.cloud_space.location
    CloudAPI::Disk.new(location)
  end

  def delete
    begin
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
    rescue RuntimeError => e
      if e.message.include?('404')
        return self
      end
    end

    self
  end

  def fetch
    self.cloud_api.find(self.cloud_id)
    rescue RuntimeError => e
      if e.message.include?('404')
        struct = Struct.new(*CloudAPI::Disk::STRUCT_FIELDS).new
        struct.status = 'DELETED'
        return struct
      end
      raise e
  end

  def resize(new_size, iops_sec=nil)
    event_started_at = Time.now
    result = self.cloud_api.resize(self.cloud_id, new_size)
    return false if result != true

    self.size = new_size
    self.iops_sec = ::Disk.calc_iops_sec(self.type, self.size, iops_sec)
    self.bytes_sec = ::Disk.calc_bytes_sec(self.type, self.size)

    cloud_api.limit_io({
      id: self.cloud_id,
      iops_sec: self.iops_sec,
      bytes_sec: self.bytes_sec,
    })

    self.save!

    event = ::Event.create({
      resource: self,
      name: 'resize',
      started_at: event_started_at,
      finished_at: Time.now,
    })

    self
  end

  def limit_io(iops_sec=nil)
    event_started_at = Time.now
    self.iops_sec = ::Disk.calc_iops_sec(self.type, self.size, iops_sec)
    self.bytes_sec = ::Disk.calc_bytes_sec(self.type, self.size)

    cloud_api.limit_io({
      id: self.cloud_id,
      iops_sec: self.iops_sec,
      bytes_sec: self.bytes_sec,
    })

    self.save!

    event = ::Event.create({
      resource: self,
      name: 'resize',
      started_at: event_started_at,
      finished_at: Time.now,
    })

    self
  end

  protected


end
