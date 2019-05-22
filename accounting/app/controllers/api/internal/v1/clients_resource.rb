# frozen_string_literal: true

module API
  class Internal::V1::ClientsResource < Internal::V1
    # helpers API::V1::Helpers
    desc 'Изменить клиента'
    params do
      requires :id, type: Integer
      requires :client, type: Hash do
        # this constants lies in users MS
        # optional :writeoff_type, type: String, values: Client::WRITEOFF_TYPES
        # optional :writeoff_interval, type: Integer, values: Client::WRITEOFF_INTERVALS
        # optional :business_entity_type, type: String, values: Client::BUSINESS_ENTITY_TYPES
        optional :discount_package_id, type: Integer
      end
    end
    put ':id', jbuilder: 'clients/show.json' do
      @client = Client.find(params[:id])
      error_422!(@client.errors) unless @client.update(declared_params[:client])
    end

    # REVIEW: block/unblock
  end
end
