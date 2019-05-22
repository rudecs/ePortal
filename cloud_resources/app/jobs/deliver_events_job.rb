class DeliverEventsJob < ApplicationJob
  queue_as :events

  def perform
    ::Event.where.not(finished_at: nil).where(delivered_at: nil).find_each do |event|
      begin
        event.deliver!
      rescue Exception => e
      end
    end
  end
end
