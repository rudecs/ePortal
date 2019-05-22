class Location < ApplicationRecord
  STATES = %w(active disabled)

  # #############################################################
  # Associations

  has_many :images
  has_many :cloud_spaces


  # #############################################################
  # Validations

  validates :code,  presence: true
  validates :url,   presence: true
  validates :state, presence: true, inclusion: { in: STATES }


  # #############################################################
  # Callbacks

  after_commit :sync_images!, on: :create

  # #############################################################
  # Scopes


  # #############################################################
  # Class methods

  def self.create!(params)
    ActiveRecord::Base.transaction do
      location = super
      struct = location.cloud_api.find(location.code)
      location.update_attributes({
        gid: struct.gid
      })

      location
    end
  end


  # #############################################################
  # Instance methods

  def cloud_api
    CloudAPI::Location.new(self)
  end

  def credentials
    $jump_scale_credentials.find {|c| c["location"] == self.code}
  end

  def sync_images!
    image_structs = ::Image.cloud_api(self).list
    image_structs.map do |image_struct|
      state = nil
      state = 'active' if image_struct.status == 'CREATED'
      state = 'processing' if image_struct.status == 'CREATING'
      state = 'deleted' if image_struct.status == 'DESTROYED'
      state = 'deleted' if image_struct.status == 'DELETED'
      state = 'failed' if image_struct.status == 'DISABLED'
      raise "Invalid cloud image status: #{image_struct.status}" if state.nil?

      image_attributes = {
        id: ::ResourceIdSequence.nextval,
        location_id: self.id,
        cloud_id: image_struct.id,
        cloud_name: image_struct.name,
        cloud_type: image_struct.type,
        cloud_status: image_struct.status,
        name: image_struct.name,
        state: state,
      }

      image = Image.find_by(image_attributes.slice(:location_id, :cloud_id))
      if image.nil?
        image = Image.create!(image_attributes)
        next
      end

      unless image.update_attributes(image_attributes.slice(:state, :cloud_status, :cloud_type, :cloud_name))
        raise image.errors
      end

    end

    image_list = self.images.where.not(cloud_id: image_structs.pluck(:id)).find_each do |image|
      unless image.update_attributes(state: 'failed')
        raise image.errors
      end
    end
  end

end
