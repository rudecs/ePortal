module Services
  module Payu
    class Base
      def initialize(payment)
        @payment = payment
      end

      def signature
        Services::Payu::Signature.new(signature_source).call
      end

      def signature_source
        # ORDER_PRICE_TYPE[] Цена продукта после применения политики по НДС. Политика применяется к значению поля ORDER_PRICE[].
        # Возможные значения: GROSS (включая НДС) и NET (НДС рассчитывается и включается PayU в стоимость заказа).
        # Значение по умолчанию: NET.
        {
          merchant: Rails.application.secrets.payu&.dig(:merchant),
          order_ref: @payment.id.to_s,
          order_date: @payment.created_at.strftime('%F %T'),
          order_pname: CONFIG.payu.desc,
          order_pcode: [@payment.id.to_s],
          order_price: [@payment.decorate.formatted_amount],
          order_qty: ['1'],
          order_vat: ['0'], # REVIEW: not sure ORDER_VAT=0 - соответствует ставке НДС в 0% (НДС не облагается)
          prices_currency: @payment.decorate.currency,
          # testorder: (!Rails.env.production?).to_s.upcase
          testorder: 'TRUE'
        }
      end
    end
  end
end
