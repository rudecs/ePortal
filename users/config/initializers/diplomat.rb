if Rails.env != 'production'
  class Diplomat::Service
    def self.get(service_name)
      config = YAML.load_file('config/diplomat.yml')[Rails.env]
      struct = OpenStruct.new
      struct.Address = config[service_name]['address']
      struct.ServicePort = config[service_name]['port']
      return struct
    end
  end
end
