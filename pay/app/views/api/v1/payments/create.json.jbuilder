json.payment do
  json.(@payment, :id)
  json.(@payment.decorate, :formatted_amount, :currency)
  json.(@service, :signature)
end

json.details do
  # json.merchant Rails.application.secrets.payu&.dig(:merchant)
  # json.url CONFIG.payu.host
  # json.product CONFIG.payu.desc
  # json.order_date @payment.created_at.strftime('%F %T')
  # json.order_qty ['1']
  # json.order_vat ['0'] # NDS

  json.merchant CONFIG.robokassa.login
  json.url CONFIG.robokassa.host
  json.product CONFIG.robokassa.desc
end

if @user.present?
  json.user(@user, :id, :email, :phone, :first_name, :last_name)
end

if @client.present?
  json.client(@client, :id, :name)
end
