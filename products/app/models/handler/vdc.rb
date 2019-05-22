class Handler::VDC < ApplicationRecord
  ACTIONS = %w(create delete)
  STATES = %w(processing completed failed)

  # #############################################################
  # Associations

  belongs_to :product_instance
  # has_many :vms,

  # #############################################################
  # Validations

  validates :product_instance, presence: true, uniqueness: true
  validates :location_id, presence: true


  # #############################################################
  # Callbacks


  # #############################################################
  # Scopes


  # #############################################################
  # Class methods


  # #############################################################
  # Instance methods

  def cloud_space
    return nil if self.cloud_space_id.nil?
    begin
      return ::Resources::CloudSpace.new.find(self.cloud_space_id)
    rescue Resources::Exceptions::NotFound => e
      return nil
    end
  end

  def cloud_resources
    @cloud_resources ||= ::CloudResources.new
    return @cloud_resources
  end

  def serialize
    {
      location_id: self.location_id,
      cloud_space_id: self.cloud_space_id,
    }
  end

  protected

end
