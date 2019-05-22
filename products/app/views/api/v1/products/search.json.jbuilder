json.products @products do |product|
  json.partial! 'products/product.json', product: product
end

json.total_count @products.count
