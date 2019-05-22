class GetCharges
  include Interactor

  def call
    validate_params!

    begin
      data = aggregate_charging_data
      context.charging_data = pretty_group data
    rescue => e
      context.fail! error: e
    end
  end

  protected

  def validate_params!
    if context.client_id.blank? || context.from.blank? || context.to.blank?
      context.fail! error: 'Did not pass all required params'
    end
  end

  def aggregate_charging_data
    query_text = "
      SELECT
        product_id,
        product_instance_id,
        resource_id,
        billing_units_digest,
        time_sequence_uid,
        key,
        count,
        sum(price) as price,
        currency,
        min(start_at) at time zone 'UTC' as start_at,
        max(end_at) at time zone 'UTC' as end_at
      FROM charges
      WHERE type = '#{resource_type}' AND client_id = #{context.client_id} AND
            start_at >= '#{context.from}' AND end_at <= '#{context.to}'
      GROUP BY
        product_id, product_instance_id, resource_id, billing_units_digest, time_sequence_uid, key, count, currency
      ORDER BY min(start_at)
    "
    ActiveRecord::Base.connection.select_all(query_text).to_hash
  end

  def pretty_group(raw_data)
    raw_data.group_by { |el| [el['resource_id'], el['billing_units_digest'], el['time_sequence_uid']] }.map do |_, data|
      data.inject({}) do |data_pretty, billing_unit_data|
        data_pretty['product_id'] = billing_unit_data['product_id']
        data_pretty['product_instance_id'] = billing_unit_data['product_instance_id']
        data_pretty['billing_data'] ||= {}
        data_pretty['billing_data'][billing_unit_data['key']] =
          { 'count' => billing_unit_data['count'],
            'price' => billing_unit_data['price'].to_f,
            'currency' => billing_unit_data['currency'] }
        data_pretty['start_at'] = billing_unit_data['start_at'].to_datetime.strftime("%F %T%:z") # "2018-05-12 08:38:06+00:00"
        data_pretty['end_at'] = billing_unit_data['end_at'].to_datetime.strftime("%F %T%:z")
        data_pretty
      end
    end
  end

  def resource_type
    context.resource_type ||= 'Charge::CloudResource'
  end
end
