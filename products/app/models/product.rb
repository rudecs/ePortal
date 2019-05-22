class Product < ApplicationRecord
  self.inheritance_column = nil

  STATES = %w(active deleted inactive)
  TYPES = %w(vdc vm arenadata)
  LOCALES=%w(ru en)
  DEFAULT_LOCALE = 'ru'

  # #############################################################
  # Associations

  has_many :product_instances

  # #############################################################
  # Validations

  validates :handler_api,   presence: true
  # validates :handler_price, presence: true
  validates :state,         inclusion: { in: STATES }
  validates :type,          inclusion: { in: TYPES }


  # #############################################################
  # Callbacks

  # #############################################################
  # Scopes


  # #############################################################
  # Class methods


  # #############################################################
  # Instance methods

  def name(locale=nil)
    locale = DEFAULT_LOCALE if locale.nil?
    return self["name_#{locale}"]
  end

  def description(locale=nil)
    locale = DEFAULT_LOCALE if locale.nil?
    return self["description_#{locale}"]
  end

  def additional_description(locale=nil)
    locale = DEFAULT_LOCALE if locale.nil?
    return self["additional_description_#{locale}"]
  end

  protected

end
