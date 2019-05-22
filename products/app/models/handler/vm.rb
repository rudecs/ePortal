class Handler::VM < ApplicationRecord

  # #############################################################
  # Associations

  belongs_to :product_instance
  belongs_to :product_instance_vdc, class_name: 'ProductInstance', required: false

  # #############################################################
  # Validations

  validates :product_instance, presence: true, uniqueness: true


  # #############################################################
  # Callbacks


  # #############################################################
  # Scopes


  # #############################################################
  # Class methods


  # #############################################################
  # Instance methods

  def machine
    return nil if self.machine_id.nil?
    begin
      return ::Resources::Machine.new.find(self.machine_id)
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
      product_instance_vdc: self.product_instance_vdc,
    }
  end

  protected

end
