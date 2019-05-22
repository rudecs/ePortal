# frozen_string_literal: true

class PayuController < ApplicationController
  # ipn route
  def ipn
    # TODO: remove logging before production
    $ipn_log.info params
    render plain: true, status: :ok && return if request.get?
    service = Services::Payu::Result.new(request.request_parameters)
    if service.valid?
      unless service.payment.paid?
        $ipn_log.info "Unpaid. #{service.payment.inspect}"
        service.verify_payment
        $ipn_log.info "Verified. #{service.payment.inspect}"
        service.payment.paid! if service.check_external_status
        $ipn_log.info "Success. #{service.payment.inspect}"
      end
      render plain: service.response # text:
    else
      $ipn_log.info 'invalid signature or currency'
      head :bad_request # resp with invalid signature or currency
    end
  end
end
