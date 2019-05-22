class CalculateBillingUnits
  BILLING_UNIT_REQUIRED_FIELDS = %w(count price currency).freeze

  include Interactor

  def call
    find_current_billing_code!

    # result = execute_code

    # context.billing_units = exclude_extra_fields!(result)
    # validate_billing_units!

    context.billing_units = execute_code
  end

  protected

  def find_current_billing_code!
    # product_instance_id = context.usage_record['product_instance_id']
    product_instance_id = context.grouping.first
    begin
      product_instance = ProductInstance.find(product_instance_id)
    rescue ActiveRecord::RecordNotFound
      context.fail! error: "Not found ProductInstance #{product_instance_id}"
    end
    unless product_instance.current_billing_code_version
      context.fail! error: "Did not find billing_code for product_instance_id #{product_instance_id}"
    end
    context.billing_code_version = product_instance.current_billing_code_version
  end

  def execute_code
    case context.billing_code_version.lang
    when 'js'
      # execute_code_js(context.billing_code_version.code, context.usage_record)

      # pass all data for ProductInstance per hour
      execute_code_js(context.billing_code_version.code, context.usage_records)
    end
  end

  def execute_code_js(code, usage_data)
    begin
      js_func = ExecJS.compile("#{code}")
      js_func.call('execute_billing_code', usage_data)
    rescue => e
      context.fail! error: e
    end
  end

  def exclude_extra_fields!(billing_units_result)
    extra_fields = %w(client_id product_id product_instance_id start_at end_at)
    billing_units_result.delete_if { |k, v| k.in? extra_fields }
  end

  def validate_billing_units!
    unless context.billing_units.is_a? Hash
      context.fail! error: "Uncorrect calculated billing_units: #{context.billing_units}"
    end
    context.billing_units.each do |billing_unit_key, values|
      unless values.keys.to_set.superset? BILLING_UNIT_REQUIRED_FIELDS.to_set
        context.fail! error: "Billing unit #{billing_unit_key} not includes required fields"
      end
    end
  end
end
