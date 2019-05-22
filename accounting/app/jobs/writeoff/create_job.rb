class Writeoff::CreateJob < ApplicationJob
  # queue_as :high. Already set in cron task
  def perform
    ActiveRecord::Base.uncached { Services::Writeoffs::Create.new(Time.current).call }
    GC.start
  end
end
