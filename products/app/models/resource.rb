class Resource < ApplicationRecord
  self.inheritance_column = nil

  TYPES = %w(cloud_space machine port disk snapshot)

  # #############################################################
  # Associations

  belongs_to :product_instance

  # #############################################################
  # Validations

  validates :product_instance, presence: true
  validates :type,             presence: true, inclusion: { in: TYPES }


  # #############################################################
  # Callbacks


  # #############################################################
  # Scopes


  # #############################################################
  # Class methods


  # #############################################################
  # Instance methods

  def fetch
    service = Diplomat::Service.get('resources')
    url = "http://#{service.Address}:#{service.ServicePort}/"
    # if Rails.env.production?
    #   service = Diplomat::Service.get('resources')
    #   url = "http://#{service.Address}:#{service.ServicePort}/"
    # else
    #   url = 'http://localhost:3001/'
    # end
    conn = Faraday.new(url: url) do |faraday|
      faraday.response :logger, ::Logger.new(STDOUT), bodies: true
      faraday.adapter  Faraday.default_adapter
      faraday.headers['Content-Type'] = 'application/json'
    end
    self.send("fetch_#{self.type}", conn)
  end

  protected

  # TODO: refactor
  def fetch_cloud_space(faraday)
    res = faraday.get("/api/resources/v1/cloud_spaces/#{self.id}.json")
    return nil if res.status != 200
    JSON.parse(res.body)['cloud_space'].merge({
      'type' => 'cloud_space',
    })
  end

  def fetch_machine(faraday)
    res = faraday.get("/api/resources/v1/machines/#{self.id}.json")
    return nil if res.status != 200
    JSON.parse(res.body)['machine'].merge({
      'type' => 'machine',
    })
  end

  def fetch_port(faraday)
    res = faraday.get("/api/resources/v1/ports/#{self.id}.json")
    return nil if res.status != 200
    JSON.parse(res.body)['port'].merge({
      'type' => 'port',
    })
  end

  def fetch_disk(faraday)
    res = faraday.get("/api/resources/v1/disks/#{self.id}.json")
    return nil if res.status != 200
    JSON.parse(res.body)['disk'].merge({
      'type' => 'disk',
    })
  end

  def fetch_snapshot(faraday)
    res = faraday.get("/api/resources/v1/snapshots/#{self.id}.json")
    return nil if res.status != 200
    JSON.parse(res.body)['snapshot'].merge({
      'type' => 'snapshot',
    })
  end
end
