# frozen_string_literal: true

module API
  class V1::PaymentsResource < API::V1
    # helpers API::V1::Helpers

    resource :payments, desc: 'Cписания' do

      helpers do
        def search_params
          declared_params[:search]
        end
      end

      desc 'Список поступлений клиента'
      params do
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 20
        optional :search, type: Hash do
          requires :client_id, type: Integer
          optional :only_money, type: Boolean
          optional :user_id, type: Integer
        end
      end
      get jbuilder: 'payments/index.json' do
        authenticate!
        error_403! unless current_clients.pluck('id').include?(params[:search][:client_id])
        @payments = PaymentsSearch.new(search_params)
                                  .results
                                  .page(params[:page])
                                  .per_page(params[:per_page])
      end
    end
  end
end
