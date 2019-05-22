locale = nil
locale = @current_user['locale'] if @current_user.present?

if product.present?
  json.id product.id
  json.type product.type
  json.name product.name(locale)
  json.description product.description(locale)
  json.additional_description product.additional_description(locale)
  json.created_at product.created_at
  json.updated_at product.updated_at
  json.deleted_at product.deleted_at
end
