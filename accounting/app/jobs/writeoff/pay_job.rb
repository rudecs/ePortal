# frozen_string_literal: true

class Writeoff::PayJob < ApplicationJob
  queue_as :default
  # retry_on Error::ServiceRequestError, wait: 1.minutes, attempts: 1, queue: :low

  def perform(writeoff_id)
    request_service = Services::Billing::Request.new(writeoff_id)
    resp = request_service.call # false / responce
    if resp
      result_service = Services::Writeoffs::Result.new(request_service.writeoff, resp)
      if result_service.charge!
        client = result_service.client
        if client.state == 'active'
          # REVIEW: writeoff = result_service.writeoff
          writeoff = client.paid_before_block
          if writeoff.paid? && client.balances_sum < writeoff.amount
            Services::Clients::Blocker.new(client).block!
          else
            result_service.predict_blocking(writeoff)
          end
        end
      end
    else
      # QueueUnpaidJob will queue unpaid periodically.
      $billing_requests_log.info "#{self.class.name} failed, writeoff_id: #{writeoff_id}"
      # raise Error::ServiceRequestError.new('No records returned or service not responded.')
    end
  end
end
