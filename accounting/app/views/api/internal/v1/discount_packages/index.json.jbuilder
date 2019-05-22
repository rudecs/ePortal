json.discount_packages @discount_packages do |dp|
  json.(dp, :id, :name)
  json.discounts dp.discount_sets do |ds|
    json.(ds, :id, :discount_id, :amount_type)
    json.amount ds.amount.to_f
    json.key_name ds.discount.key_name
  end
end
