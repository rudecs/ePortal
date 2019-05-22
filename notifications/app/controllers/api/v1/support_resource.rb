# frozen_string_literal: true

module API
  class V1::SupportResource < API::V1
    resource :support, desc: 'Обратная связь' do
      helpers do
        def support_request
          return false unless Rails.application.secrets.support_service_url.present? && Rails.application.secrets.support_service_token.present?
          Faraday.new(url: Rails.application.secrets.support_service_url) do |faraday|
            faraday.response :logger, ::Logger.new(STDOUT), bodies: true
            faraday.adapter  Faraday.default_adapter
            faraday.headers['Content-Type'] = 'application/json'
            faraday.headers['Authorization'] = ['Token', Rails.application.secrets.support_service_token].join(' ')
          end
        end

        def handle_response(res)
          if [400, 401, 404].include?(res.status)
            public_send("error_#{res.status}!")
          elsif res.status >= 400
            public_send("error_#{res.status}!", errors: res.body)
          else
            JSON.parse(res.body)
          end
        end
      end

      desc 'Список тикетов'
      get '/tickets/search' do
        ### common code
        authenticate!
        conn = support_request
        error_500!(support_service: 'undefined') unless conn
        ###

        auth_res = conn.get do |req|
          req.url '/api/v1/users/search', { query: ['email', current_user['email']].join(':') }
        end

        customer_id = handle_response(auth_res)&.first&.dig('id')
        return [] unless customer_id

        tickets_res = conn.get do |req| # TODO: self path, self.method
          req.url '/api/v1/tickets/search', { query: ['customer_id', customer_id].join(':') } # query: { params }
        end
        result = handle_response(tickets_res)
        {
          ticket: result.dig('assets', 'Ticket'),
          total_count: result['tickets_count']
        }
      end

      desc 'Просмотр тикета'
      params do
        requires :id, type: Integer
      end
      get '/tickets/:id' do
        ### common code
        authenticate!
        conn = support_request
        error_500!(support_service: 'undefined') unless conn
        ###

        auth_res = conn.get do |req|
          req.url '/api/v1/users/search', { query: ['email', current_user['email']].join(':') }
        end

        customer_id = handle_response(auth_res)&.first&.dig('id')
        return [] unless customer_id

        show_ticket = conn.get do |req|
          req.url "/api/v1/tickets/#{params[:id]}"
        end
        ticket = handle_response(show_ticket)
        error_403! unless ticket&.dig('customer_id') == customer_id

        ticket_articles = conn.get do |req|
          req.url "/api/v1/ticket_articles/by_ticket/#{params[:id]}"
        end
        {
          ticket: ticket,
          articles: handle_response(ticket_articles)
        }
      end

      desc 'create ticket' # POST /api/v1/tickets
      # params do
        # title:admin token used to create ticket 3
        # group:Users
        # customer:notifications.staging@yandex.ru
        # article[subject]:article subject 3
        # article[body]:article and ticket created for user notifications.staging
        # article[type]:note
        # article[internal]:false
        # article[sender]:Customer
        # note:some ticket-user note?!
      # end
      post '/tickets' do
        # REVIEW: save customer_id in client?

        ### common code
        authenticate!
        conn = support_request
        error_500!(support_service: 'undefined') unless conn
        ###

        resp = conn.post('/api/v1/tickets') do |req|
          # req.headers['X-On-Behalf-Of'] = current_user['email']
          req.body = params.deep_merge(
            group: 'Users',
            customer_id: ['guess', current_user['email']].join(':'), # customer: current_user['email'],
            article: {
              type: 'note',
              internal: false,
              sender: 'Customer',
            }
          ).to_json
        end
        handle_response(resp)
      end

      desc 'create article' # /api/v1/ticket_articles
      # {"ticket_id":"336","type":"note","body":"1","customer":"notifications.staging@yandex.ru"}
      post '/ticket_articles' do
        ### common code
        authenticate!
        conn = support_request
        error_500!(support_service: 'undefined') unless conn
        ###

        auth_res = conn.get do |req|
          req.url '/api/v1/users/search', { query: ['email', current_user['email']].join(':') }
        end

        customer_id = handle_response(auth_res)&.first&.dig('id')
        error_404! unless customer_id

        show_ticket = conn.get do |req|
          req.url "/api/v1/tickets/#{params[:ticket_id]}"
        end
        ticket = handle_response(show_ticket)
        error_403! unless ticket&.dig('customer_id') == customer_id

        # ticket_id?!
        # "time_unit": "12"
        resp = conn.post('/api/v1/ticket_articles') do |req|
          req.headers['X-On-Behalf-Of'] = current_user['email']
          req.body = params.merge(
            sender: 'Customer',
            type: 'note',
            internal: false,
            content_type: 'text/html'
          ).to_json
        end
        handle_response(resp)
      end

      # desc 'create users' # POST /api/v1/users
      # "firstname": "Bob",
      # "lastname": "Smith",
      # "email": "bob@smith.example.com",
      # "organization": "Some Organization Name",
    end
  end
end
