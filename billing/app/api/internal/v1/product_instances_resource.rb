class Internal::V1::ProductInstancesResource < Internal::V1::Base
  resource :product_instances do
    desc 'Update product instance with billing code'
    params do
      requires :product_instance, type: Hash do
        requires :code, type: String
        requires :lang, type: String, values: BillingCodeVersion::LANGUAGES
      end
    end
    post ':id' do
      result = UpdateProductInstance.call(product_instance_id: params[:id],
                                          code: params[:product_instance][:code],
                                          lang: params[:product_instance][:lang])
      if result.success?
        { product_instance: { id: result.product_instance_id.to_i, code: result.billing_code_version.code, lang: result.billing_code_version.lang } }
      else
        error!({ message: result.error }, 500)
      end
    end
  end
end
