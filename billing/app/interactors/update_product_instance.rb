class UpdateProductInstance
  include Interactor

  def call
    validate_params!

    begin
      ActiveRecord::Base.transaction do
        find_or_create_product_instance!
        create_billing_code_version!
        set_current_billing_code_version!
      end
    rescue => e
      context.fail! error: e
    end
  end

  protected

  def validate_params!
    if context.product_instance_id.blank? || context.code.blank? || context.lang.blank?
      context.fail! error: 'Missing required params for update product_instance'
    end
  end

  def find_or_create_product_instance!
    context.product_instance = ProductInstance.find_or_create_by!(id: context.product_instance_id)
  end

  def create_billing_code_version!
    context.billing_code_version = BillingCodeVersion.create!(product_instance_id: context.product_instance_id, code: context.code, lang: context.lang)
  end

  def set_current_billing_code_version!
    product_instance = context.product_instance
    product_instance.update(current_billing_code_version_id: context.billing_code_version.id)
    context.product_instance.reload
  end
end
