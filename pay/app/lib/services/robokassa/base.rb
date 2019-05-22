module Services
  module Robokassa
    class Base
      def initialize(payment)
        @payment = payment
      end

      def signature
        Digest::MD5.hexdigest signature_source
      end

      private

      # Для работы в тестовом режиме  обязателен параметр  IsTest.

      # Но, если стоимость товаров у Вас на сайте указана, например, в долларах, то при выставлении счёта к оплате
      # Вам необходимо указывать уже пересчитанную сумму из долларов в рубли. См. необязательный параметр OutSumCurrency.

      # OutSumCurrency
      # Способ указать валюту, в которой магазин выставляет стоимость заказа. Этот параметр нужен для того,
      # чтобы избавить магазин от самостоятельного пересчета по курсу. Является дополнительным к обязательному параметру OutSum.
      # Если этот параметр присутствует, то OutSum показывает полную сумму заказа, конвертированную из той валюты,
      # которая указана в параметре OutSumCurrency, в рубли по курсу ЦБ на момент оплаты. Может принимать значения: USD, EUR и KZT.

      # MerchantLogin:OutSum:InvId:OutSumCurrency:Пароль#1
      def signature_source
        base_params = [
          CONFIG.robokassa.login,
          @payment.decorate.formatted_amount,
          @payment.id,
          receipt
        ]

        currency = @payment.decorate.currency
        base_params.push(currency) unless currency.casecmp?('rub')

        base_params.push Rails.application.secrets.robokassa&.dig(:robokassa_pass1)
        base_params.join(':')
      end

      def receipt
        json = {
          items: [
            {
              name: CONFIG.robokassa.desc,
              quantity: 1.0,
              sum: @payment.decorate.formatted_amount,
              tax: 'vat0'
            }
          ]
        }.to_json
        URI.encode(json)
      end
    end
  end
end
