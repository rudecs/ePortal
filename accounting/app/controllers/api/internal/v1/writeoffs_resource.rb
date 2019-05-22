# frozen_string_literal: true

module API
  class Internal::V1::WriteoffsResource < Internal::V1
    resource :writeoffs, desc: 'Cписания' do

      helpers do
      end

      desc 'Список списаний клиента'
      params do
        requires :client_id, type: Integer
        # optional :from, type: Time
        # optional :to, type Time
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 20
      end
      get jbuilder: 'writeoffs/index.json' do
        prms = declared_params
        @writeoffs =
          Writeoff.paid
                  .where(client_id: prms[:client_id])
                  .select(<<-SQL.squish)
                    DATE_TRUNC(
                      'Month',
                      end_date::TIMESTAMPTZ AT TIME ZONE '#{Time.zone.now.formatted_offset}'::INTERVAL
                    )::date AS writeoff_month,
                    SUM(amount) AS amount_sum,
                    SUM(initial_amount) AS initial_amount_sum
                  SQL
                  .group('writeoff_month')
                  .order('writeoff_month DESC')
                  .page(params[:page]).per_page(params[:per_page])
      end

      desc 'Подробная информация о cписании'
      params do
        requires :client_id, type: Integer
        requires :date, type: Date # actually we need month and year
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 20
      end
      get :show, jbuilder: 'writeoffs/show.json' do
        start_at = params[:date].beginning_of_month.in_time_zone
        error_404! if start_at > Time.current
        end_at = params[:date].to_time.end_of_month.in_time_zone

        @writeoffs = Writeoff.paid
                             .where(client_id: params[:client_id], end_date: start_at..end_at)
                             .includes(:product_instance_states, :payment_transactions)
                             .order(end_date: :desc)
                             .page(params[:page])
                             .per_page(params[:per_page])
      end
    end
  end
end
