class PaymentDecorator < Draper::Decorator
  PAYU_GATEWAYS = {
    'QIWI' => 'Qiwi',
    'Visa/MasterCard/Eurocard' => 'Банковская карта',
    'WEBMONEY' => 'Электронный кошелек',
    'YANDEX' => 'Яндекс-деньги', # WTF (Важно! Не применимо для новых клиентов)
    # WTF??? external api ALFACLICK (в некоторых случаях приходит "АЛЬФА-КЛИК")
    'ALFACLICK' => 'Альфа-клик',
    'АЛЬФА-КЛИК' => 'Альфа-клик',
    'EUROSET_SVYAZNOI' => 'Сеть салонов Евросеть, Связной',
    'PAYU_CREDIT' => 'PayU' # (информацию по этому методу вам нужно запросить отдельно у вашего менеджера)
  }.freeze

  ROBOKASSA_GATEWAYS = {
    'Qiwi' => 'Qiwi',
    'BankCard' => 'Банковская карта',
    'EMoney' => 'Электронный кошелек',
    'eInvoicing' => 'Интернет-банк',
    'MobileCommerce' => 'Мобильный платеж',
    'Rapida' => 'Евросеть',
    'RapidaSvyaznoy' => 'Связной'
  }.freeze

  def formatted_amount
    format('%.2f', object.amount)
  end

  def currency
    object.currency.upcase
  end

  def payment_method
    if object.payment_method.present?
      [object.gateway.upcase, 'GATEWAYS'].join('_').constantize[object.payment_method]
    else
      'Нет информации'
    end
  end
end
