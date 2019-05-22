class ChargeCostByUsageRecord
  USAGE_RECORD_REQUIRED_FIELDS = %w(client_id product_id product_instance_id start_at end_at).freeze

  include Interactor
  # TODO: no need for usage_record! make it through billing units

  def call
    return if miss_recalculate_existed_records? && charge_records_by_usage_record_exist?

    # validate_usage_record!

    # context.billing_code_version = result.billing_code_version

    calculate_billing_units_digest!

    if previous_same_billing_record
      context.time_sequence_uid = previous_same_billing_record.time_sequence_uid
    else
      context.time_sequence_uid = generate_uid
    end

    save_charging!
  end

  protected

  def miss_recalculate_existed_records?
    context.mode == :miss_recalculate_existed_records
  end

  def charge_records_by_usage_record_exist?
    Charge::Base.where(type: resource_type,
                       resource_id: resource_id,
                       start_at: context.billing_units['start_at'],
                       end_at: context.billing_units['end_at']).exists?
  end

  # def validate_usage_record!
  #   usage_record = context.usage_record
  #   context.fail!(error: "usage_record #{usage_record} is not hash") unless usage_record.is_a? Hash
  #   unless usage_record.keys.to_set.superset? USAGE_RECORD_REQUIRED_FIELDS.to_set
  #     context.fail! error: "usage_record #{usage_record} not valid! Missing some required fields"
  #   end
  # end

  def calculate_billing_units_digest!
    md5_digest = HashToMD5.new(context.billing_units['prices']).run
    context.billing_units_digest = md5_digest
  end

  def previous_same_billing_record
    previous_start_at = (context.billing_units['start_at'].to_time - 1.hour)
    previous_end_at = (context.billing_units['end_at'].to_time - 1.hour)
    Charge::Base.find_by(type: resource_type, resource_id: resource_id,
                         billing_units_digest: context.billing_units_digest,
                         start_at: previous_start_at, end_at: previous_end_at)
  end

  def generate_uid
    SecureRandom.uuid
  end

  def save_charging!
    # REVIEW: should do the job
    context.billing_units['prices'].each do |unit_key, billing_unit_data|
      billing_unit = { 'key' => unit_key }.merge billing_unit_data
      save_charging_record! billing_unit
    end

    # REVIEW: make it work with hash, string. Currently, billing_unit is_a Array
    # what should be in billing_units.last?
    # Example: billing_units = ["cpu", {"count"=>1, "price"=>0.3889, "currency"=>"rub"}]
    # billing_unit = { 'key' => context.billing_units.first }.merge(context.billing_units.last)
    # save_charging_record! billing_unit
  end

  def save_charging_record!(billing_unit)
    charge_record = Charge::Base.find_or_initialize_by(
      client_id: context.billing_units['client_id'],
      product_id: context.billing_units['product_id'],
      product_instance_id: context.billing_units['product_instance_id'],
      type: resource_type,
      resource_id: resource_id,
      # resource_kind: billing_units['resource'],
      key: billing_unit['key'],
      start_at: context.billing_units['start_at'],
      end_at: context.billing_units['end_at']
    )

    charge_record.billing_units_digest = context.billing_units_digest
    charge_record.time_sequence_uid = context.time_sequence_uid
    charge_record.count = billing_unit['count']
    charge_record.currency = billing_unit['currency']
    charge_record.price = billing_unit['price']
    charge_record.billing_code_version_id = context.billing_code_version.id

    begin
      charge_record.save!
      context.charge_records ||= []
      context.charge_records.push charge_record
    rescue => e
      context.fail! error: e
    end
  end

  def resource_type
    context.resource_type ||= 'Charge::ProductInstance'
  end

  def resource_id
    case resource_type
    when 'Charge::ProductInstance'
      context.billing_units['product_instance_id'] # default
    when 'Charge::CloudResource'
      context.billing_units['id'] # not use now. Maybe in future
    end
  end
end
