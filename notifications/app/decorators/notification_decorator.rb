class NotificationDecorator < Draper::Decorator
  def content
    ActionController::Base.helpers.strip_tags(object&.content)&.squish
  end

  def subject
    # adds extra queries on array of records unless .includes(template: :templates_set)
    template = object.template
    return nil unless template
    return template.subject if template.subject # can be nil
    key_name = template&.templates_set&.key_name
    return nil unless key_name
    locale = I18n.available_locales.map(&:to_s).include?(template.locale) ? template.locale.to_sym : I18n.default_locale
    I18n.t(key_name, scope: :subjects, default: nil, locale: locale)
  end
end
