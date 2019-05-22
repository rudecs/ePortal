# frozen_string_literal: true

module Services
  module Clients
    class Request
      attr_reader :notification_request

      def initialize(request, pagination = nil)
        @notification_request = request
        @pagination = pagination
      end

      def call
        begin
          clients_request
        rescue
          false
        end
      end

      private

      def clients_request
        url = clients_url
        raise 'clients is not avaliable' unless url

        response = Faraday.get url, {
          search: search_params
        }
        JSON.parse(response.body)
      end

      def clients_url
        service = Diplomat::Service.get('users')
        return false if service&.Address.nil?
        "http://#{service.Address}:#{service.ServicePort}/api/internal/v1/users"
      end

      def search_params
        search = { roles: @notification_request.category }
        search[:client_ids] = @notification_request.client_ids if @notification_request.client_ids.present?
        search[:ids] = @notification_request.user_ids if @notification_request.user_ids.present?
        search
      end
    end
  end
end
