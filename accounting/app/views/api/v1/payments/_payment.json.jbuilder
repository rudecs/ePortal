if payment.present?
  json.(payment, :id, :client_id,
                 :amount, :currency,
                 :puid, :source,
                 :created_at, :updated_at)
end
