class Event < ApplicationRecord
  NAMES = %w(create resize delete start stop)

  # #############################################################
  # Associations

  belongs_to :resource, polymorphic: true


  # #############################################################
  # Validations

  validates :name, presence: true, inclusion: { in: NAMES }


  # #############################################################
  # Callbacks


  # #############################################################
  # Scopes


  # #############################################################
  # Class methods


  # #############################################################
  # Instance methods

  def deliver!
    return true if self.delivered_at.present?

    unless self.finished_at.present?
      err_message = {finished_at: ["can't be blank"]}.to_json
      raise err_message
    end

    self.set_params

    resource = self.resource
    request_params = {
      event_started_at: self.started_at,
      event_finished_at: self.finished_at,
      event: self.name,
      resource: self.resource_type.underscore,
      resource_id: self.resource_id,
      product_id: resource.product_id,
      client_id: resource.client_id,
      partner_id: 1, #resource.partner_id,
      product_instance_id: resource.product_instance_id,
    }.merge(self.params)

    if Rails.env == 'development'
      puts '================================'
      puts 'Event#send_to_usage'
      puts JSON.pretty_generate(request_params)
      puts '================================'
      self.delivered_at = Time.now
      self.save!
      return
    end

    service = Diplomat::Service.get('usage')
    url = "http://#{service.Address}:#{service.ServicePort}/"

    conn = Faraday.new(url: url) do |faraday|
      faraday.response :logger, ::Logger.new(STDOUT), bodies: true
      faraday.adapter  Faraday.default_adapter
      faraday.headers['Content-Type'] = 'application/json'
    end

    res = conn.post('/api/usage/v1/resources.json') do |req|
      req.body = request_params.to_json
    end

    if res.status != 200 && res.status != 201
      raise res.body
    end

    self.delivered_at = Time.now
    self.save!
  end

  protected

  def set_params
    self.params ||= {}
    resource_attributes = resource.attributes
    self.params = self.params.merge(resource_attributes.slice(*%w(
      size cloud_type iops_sec bytes_sec
      memory vcpus
      state status
    )))

    if self.resource_type == 'Disk'
      self.params['disk_type'] = resource_attributes['type']
    end

    if self.resource_type == 'Machine' && self.name == 'create'
      self.params['image_name'] = self.resource.image.name
    end

    self.save!

    self.params
  end

end
