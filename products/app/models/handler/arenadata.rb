class Handler::Arenadata < ApplicationRecord

  def self.table_name
    'handler_arenadatas'
  end

  # #############################################################
  # Associations

  belongs_to :product_instance

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

  def cloud_resources
    @cloud_resources ||= ::CloudResources.new
    return @cloud_resources
  end

  protected

end
