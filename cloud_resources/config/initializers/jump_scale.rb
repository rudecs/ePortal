secrets = YAML.load_file('config/secrets.yml')[Rails.env]

$jump_scale_credentials = secrets['jump_scale_credentials']


raise '!!! You have to set jump_scale_cookie. !!!'  if $jump_scale_credentials.blank?
