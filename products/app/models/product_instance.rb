class ProductInstance < ApplicationRecord
  STATES = %w(creating processing active deleted failed)

  # #############################################################
  # Associations

  belongs_to :product
  has_many :resources
  has_many :jobs, class_name: 'ProductInstanceJob'

  # #############################################################
  # Validations

  validates :product,       presence: true
  validates :client_id,     presence: true
  # validates :department_id, presence: true
  validates :state,         inclusion: { in: STATES }
  # validates :name, presence: true


  # #############################################################
  # Callbacks

  after_commit :send_handler_price_to_billing, on: [:create, :update]

  # #############################################################
  # Scopes

  scope :enabled, -> { where(disabled_at: nil) }
  scope :disabled, -> { where.not(disabled_at: nil) }

  # #############################################################
  # Class methods


  # #############################################################
  # Instance methods


  def fetch_resources
    service = Diplomat::Service.get('resources')
    url = "http://#{service.Address}:#{service.ServicePort}/"

    conn = Faraday.new(url: url) do |faraday|
      faraday.response :logger, ::Logger.new(STDOUT), bodies: true
      faraday.adapter  Faraday.default_adapter
      faraday.headers['Content-Type'] = 'application/json'
    end

    result = []
    result += self.fetch_cloud_spaces(conn)
    result += self.fetch_machines(conn)
    result += self.fetch_disks(conn)
    result += self.fetch_snapshots(conn)
    result += self.fetch_ports(conn)
    result
  end

  def fetch_cloud_spaces(faraday)
    url = '/api/resources/v1/cloud_spaces.json'
    request_params = {
      search: {
        product_instance_id: self.id,
        state: 'active',
      }
    }

    res = faraday.get(url, request_params)

    JSON.parse(res.body)['cloud_spaces']
  end

  def fetch_machines(faraday)
    url = '/api/resources/v1/machines.json'
    request_params = {
      search: {
        product_instance_id: self.id,
        state: 'active',
      }
    }

    res = faraday.get(url, request_params)

    JSON.parse(res.body)['machines']
  end

  def fetch_disks(faraday)
    url = '/api/resources/v1/disks.json'
    request_params = {
      search: {
        product_instance_id: self.id,
        state: 'active',
      }
    }

    res = faraday.get(url, request_params)

    JSON.parse(res.body)['disks']
  end

  def fetch_snapshots(faraday)
    url = '/api/resources/v1/snapshots.json'
    request_params = {
      search: {
        product_instance_id: self.id,
        state: 'active',
      }
    }

    res = faraday.get(url, request_params)

    JSON.parse(res.body)['snapshots']
  end

  def fetch_ports(faraday)
    url = '/api/resources/v1/ports.json'
    request_params = {
      search: {
        product_instance_id: self.id,
        state: 'active',
      }
    }

    res = faraday.get(url, request_params)

    JSON.parse(res.body)['ports']
  end

  def handler
    return @handler if @handler.present?
    handler_class = self.product.handler_api.constantize#.new(self)
    @handler = handler_class.find_by_product_instance_id(self.id)
  end

  def reload_playbook
    self.handler_api.new(self).reload
  end

  def soft_disable
    touch :disabled_at
  end

  def soft_disabled?
    disabled_at.present?
  end

  def soft_restore
    update_column(:disabled_at, nil)
  end

  protected

  def send_handler_price_to_billing
    request_params = {
      product_instance: {
        code: self.handler_price,
        lang: 'js',
      },
    }

    if Rails.env == 'development'
      puts '========================='
      puts 'ProductInstance#send_handler_price_to_billing'
      puts request_params
      puts '========================='
      return
    end

    service = Diplomat::Service.get('billing')
    url = "http://#{service.Address}:#{service.ServicePort}/"

    conn = Faraday.new(url: url) do |faraday|
      faraday.response :logger, ::Logger.new(STDOUT), bodies: true
      faraday.adapter  Faraday.default_adapter
      faraday.headers['Content-Type'] = 'application/json'
    end

    res = conn.post("/api/billing/v1/product_instances/#{self.id}.json") do |req|
      req.body = request_params.to_json
    end
  end

end
