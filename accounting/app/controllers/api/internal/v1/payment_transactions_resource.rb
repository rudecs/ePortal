module API
  class Internal::V1::PaymentTransactionsResource < Internal::V1
    # helpers API::V1::Helpers
    PERIODS = {
      '24hours' => 24.hours,
      '1week' => 1.week,
      '1month' => 1.month,
    }.freeze

    resource :payment_transactions, desc: 'Платежи' do

      helpers do
        def search_params
          declared_params[:search]
        end

        def one_c_params
          prms = declared_params[:search]
          error_422!(to: 'invalid') if prms[:to] > Time.current

          period_keys = PERIODS.keys
          error_422!(period: "valid values are #{period_keys}") unless period_keys.include?(prms[:period])
          prms[:from] = prms[:to] - PERIODS[prms[:period]]

          prms.merge(subject_type: 'Writeoff', account_type: 'money')
        end
      end

      desc 'Список платежей клиента'
      params do
        requires :search, type: Hash, default: {} do
          requires :client_id, type: Integer
          # optional :from, type: DateTime
          # optional :to, type: DateTime
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 20
        end
      end
      get '/search', jbuilder: 'payment_transactions/index.json' do
        prms = search_params
        @payment_transactions = PaymentTransaction.where(client_id: prms[:client_id])
                                                  .includes(:subject)
                                                  .page(prms[:page])
                                                  .per_page(prms[:per_page])
      end

      # 1C integration
      desc 'Список расходов клиентов'
      params do
        optional :search, type: Hash, default: {} do
          optional :client_id, type: Integer
          optional :client_ids, type: Array[Integer]
          optional :to, type: DateTime, default: Time.current
          optional :period, type: String, default: '24hours'
        end
      end
      get '/1c_search', jbuilder: 'payment_transactions/search.json' do
        search = PaymentTransactionsSearch.new(one_c_params)
        # search.options[:from], search.options[:to] to get datetime
        @payment_transactions = search.results
      end
    end
  end
end
