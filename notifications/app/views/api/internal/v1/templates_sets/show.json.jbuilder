json.(@templates_set, :id, :key_name, :category)
json.templates @templates_set.templates do |tmpl|
  json.(tmpl, :id, :content, :locale, :delivery_method, :subject)
end
