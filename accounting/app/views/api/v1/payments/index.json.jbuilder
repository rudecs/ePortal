json.payments @payments do |payment|
  json.partial! 'clients/payment.json', payment: payment
end

json.total_count @payments.total_entries
