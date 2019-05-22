json.writeoffs @writeoffs do |writeoff|
  json.(writeoff, :amount_sum, :initial_amount_sum, :writeoff_month)
end

json.total_count @writeoffs.total_entries
