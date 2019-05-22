json.templates_sets @templates_sets do |ts|
  json.(ts, :id, :key_name, :category) # TODO: decorate category?
  json.templates ts.templates do |tmpl|
    json.(tmpl, :id, :content, :locale, :delivery_method, :subject)
  end
end
