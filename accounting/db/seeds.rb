puts '=== Start loading seeds ==='

# === Default VDC discount ===
ip_discount = Discount.find_or_create_by(key_name: 'ip_address')
# bandwidth_discount = Discount.find_or_create_by(key_name: 'bandwidth')
discount_package = DiscountPackage.find_or_create_by(name: 'VDC default')
DiscountSet.find_or_create_by(amount: 1, amount_type: 'quantity', discount: ip_discount, discount_package: discount_package)
# DiscountSet.find_or_create_by(amount: 10, amount_type: 'quantity', discount: bandwidth_discount, discount_package: discount_package)

# Client.where(discount_package_id: nil).update_all(discount_package: discount_package)

puts '=== Loading seeds completed ==='
