class ProductInstanceJob < ApplicationRecord
  STATES = %w(new processing completed failed)

  # #############################################################
  # Associations

  belongs_to :product_instance


  # #############################################################
  # Validations

  validates :product_instance,       presence: true
  # validates :handler_fn_name, presence: true
  # validates :handler_fn_params, presence: true
  validates :state,         presence: true, inclusion: { in: STATES }

  # #############################################################
  # Callbacks

  # after_commit :update_product_instance_state, on: [:create, :update]


  # #############################################################
  # Scopes


  # #############################################################
  # Class methods


  # #############################################################
  # Instance methods

  def process
    # self.update_attributes(state: 'processing')
    interactor = "::#{self.handler.class.name}::#{self.action_name.camelcase}".constantize
    context = interactor.call({
      product_instance: self.product_instance,
      handler: self.handler,
      job: self,
    })
    if context.failure?
      self.error_messages ||= []
      self.error_messages << context.errors if context.errors.present?
      self.save
    end
    context
  end

  # def execute
  #   self.handler.send(self.handler_fn_name)
  # end
  #
  def handler
    @handler ||= self.product_instance.handler
  end
  #
  # def reload
  #   self.handler.reload
  #   # super
  # end

  protected

  # def update_product_instance_state
  # end

end
