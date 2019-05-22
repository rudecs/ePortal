# frozen_string_literal: true

module Services
  module Billing
    class Request
      attr_reader :writeoff

      def initialize(writeoff_id)
        @writeoff = Writeoff.find(writeoff_id)
      end

      def call
        begin
          resp = request_billing_data['data']
          resp.is_a?(Array) && (resp.any? || @writeoff.created_at < 3.hours.ago) ? resp : false
        rescue
          false
        end
      end

      private

      def request_billing_data
        url = billing_url
        raise 'billing is not avaliable' unless url

        response = Faraday.get url, { charges: { from: @writeoff.start_date, to: @writeoff.end_date, client_id: @writeoff.client_id }}
        JSON.parse(response.body)
      end

      def billing_url
        service = Diplomat::Service.get('billing')
        return false if service&.Address.nil?
        "http://#{service.Address}:#{service.ServicePort}/api/billing/v1/charges"
      end
    end
  end
end
