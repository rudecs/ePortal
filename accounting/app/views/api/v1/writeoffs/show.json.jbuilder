json.writeoffs @writeoffs do |w|
  json.(w, :id, :amount, :initial_amount, :start_date, :end_date)
  json.billing w.product_instance_states.group_by(&:product_instance_id).each do |id, instances|
    json.product_instance_id id
    json.states instances do |i|
      json.(i, :id, :product_id, :product_instance_id, :billing_data, :start_at, :end_at)
    end
  end
end

json.total_count @writeoffs.total_entries
