class Payment::QueueUnchargedJob < ApplicationJob
  def perform
    Payment.paid.uncharged.pluck(:id).each do |id|
      Payment::ChargeJob.perform_later(id)
    end
  end
end
