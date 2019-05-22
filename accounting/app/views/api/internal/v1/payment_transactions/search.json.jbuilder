json.payment_transactions @payment_transactions.group_by(&:client_id).each do |client_id, payment_transactions|
  json.set! client_id do
    json.array! payment_transactions.each do |trns|
      json.(trns, :id, :client_id, :created_at, :currency)
      json.amount trns.amount.to_f
    end
  end
end
