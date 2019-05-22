require 'hmac-md5'

module Services
  module Payu
    class Signature
      def initialize(hash)
        @hash = hash.dup # ?
      end

      def call
        # OR in production: config.require_master_key = true
        # Rails.application.credentials.payu&.dig(:secret).presence ||
        HMAC::MD5.new(Rails.application.secrets.payu&.dig(:secret)).update(bytesized_hash).hexdigest # RuntimeError: if scrt = nil
      end

      private

      def bytesized_hash
        result = ''
        @hash.delete(:testorder) if @hash[:testorder] != 'TRUE'
        @hash.values.flatten.each { |value| result << "#{value.to_s.bytesize}#{value}" }

        result
      end
    end
  end
end
