class Writeoff::QueueUnpaidJob < ApplicationJob
  def perform
    # Writeoff.unpaid.pluck(:id).each do |id|
    #   Writeoff::PayJob.perform_later(id) # can i check if same job is in the queue?
    # end
    ActiveRecord::Base.uncached do
      Writeoff.unpaid.in_batches(of: 100) do |batch|
        # batch.pluck(:id).each. In case when where_values_hash might stop providing ids
        batch.where_values_hash['id'].each { |id| Writeoff::PayJob.perform_later(id) }
      end
    end
  end
end
