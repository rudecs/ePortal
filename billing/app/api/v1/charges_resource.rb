class V1::ChargesResource < V1::Base
  resource :charges do
    desc 'Get aggregated data of charges by client'
    params do
      requires :charges, type: Hash do
        requires :client_id, type: Integer
        requires :from, type: DateTime
        requires :to, type: DateTime
        optional :resource_type, type: String, values: ['Charge::ProductInstance', 'Charge::CloudResource']
      end
    end
    get '/' do
      result = GetCharges.call(client_id: params['charges']['client_id'],
                               from: params['charges']['from'],
                               to: params['charges']['to'],
                               resource_type: params['charges']['resource_type'])
      if result.success?
        { data: result.charging_data }
      else
        error!({ message: result.error }, 500)
      end
    end
  end
end
