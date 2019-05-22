class Snapshot < ApplicationRecord
  include ResourcesStates

  # #############################################################
  # Associations

  belongs_to :machine


  # #############################################################
  # Validations

  validates :machine, presence: true
  validates :state, presence: true, inclusion: { in: STATES }
  validates :cloud_name, presence: true
  # validates :cloud_epoch, presence: true


  # #############################################################
  # Callbacks


  # #############################################################
  # Scopes


  # #############################################################
  # Class methods

  def self.cloud_api(location)
    location = ::Location.find(location) if location.class == Integer
    CloudAPI::Snapshot.new(location)
  end

  def self.create!(params)
    event_started_at = Time.now
    snapshot = nil
    ActiveRecord::Base.transaction do
      params = params.symbolize_keys
      params[:id] = ::ResourceIdSequence.nextval unless params[:id].present?
      params[:cloud_name] = "snapshot_#{params[:id].to_s}"
      params[:state] = 'processing'
      self.new(params).validate!

      machine = ::Machine.find(params[:machine_id])
      location = machine.cloud_space.location
      snapshot_struct = self.cloud_api(location).create({
        machine_id: machine.cloud_id,
        name: params[:cloud_name],
      })

      params[:cloud_name] = snapshot_struct.name
      params[:cloud_epoch] = snapshot_struct.epoch
      params[:state] = 'active'
      snapshot = super
    end

    event = ::Event.create({
      resource: snapshot,
      name: 'create',
      started_at: event_started_at,
      finished_at: Time.now,
    })

    snapshot
  end


  # #############################################################
  # Instance methods

  def cloud_api
    location = self.machine.cloud_space.location
    CloudAPI::Snapshot.new(location)
  end

  def delete
    event_started_at = Time.now
    result = self.cloud_api.delete(self.machine.cloud_id, self.cloud_name)
    return false if result != true
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

  def rollback
    event_started_at = Time.now
    result = self.cloud_api.rollback(self.machine.cloud_id, self.cloud_name, self.cloud_epoch)
    return false if result != true
    Snapshot.
    where(machine_id: self.machine_id).
    where(state: 'active').
    where('snapshots.cloud_epoch > ?', self.cloud_epoch).
    find_each do |snapshot|
      snapshot.update_attributes({
        state: 'deleted',
        deleted_at: Time.now,
      })

      event = ::Event.create({
        resource: snapshot,
        name: 'delete',
        started_at: event_started_at,
        finished_at: Time.now,
      })
    end
  end


  protected


end
