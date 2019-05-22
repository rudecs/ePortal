json.payment_transactions @payment_transactions.each do |payment_transaction|
  json.(payment_transaction, :id, :subject_id, :subject_type, :amount, :currency, :client_id, :account_type, :created_at)
  if payment_transaction.subject.present?
    json.subject payment_transaction.subject
  end
end

json.total_count @payment_transactions.total_entries
