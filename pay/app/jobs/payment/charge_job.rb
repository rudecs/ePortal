class Payment::ChargeJob < ApplicationJob
  def perform(payment_id)
    service = Services::Accounting::Charge.new(payment_id)
    resp = service.accounting_charge
    if resp && resp.dig(:payment, :id)
      service.charge_payment!
    else
      msg = "#{self.class.name} failed, payment_id: #{payment_id}"
      msg << "; Error: #{resp['error']}" if resp && resp['error']
      $accounting_requests_log.info msg
    end
  end
end
