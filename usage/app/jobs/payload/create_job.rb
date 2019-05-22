# frozen_string_literal: true

class Payload::CreateJob < ApplicationJob
  def perform
    task_start_time = Time.current # time can be a variable
    period_start = task_start_time.beginning_of_hour
    period_end = task_start_time.end_of_hour

    $hourly_reports_log.info "=== Start task at (#{task_start_time}) ==="
    $hourly_reports_log.info "Billing period: from #{period_start} to #{period_end}."

    # warning: fake_event's times must be > beginnig of hour,
    # "resize" event should be used cause of no special logic tied.
    fake_event = Event.new(name: 'resize', started_at: period_end, finished_at: period_end)
    payloads_created_count = 0

    # ids to exclude: active resources, that already have usages for period. Payload period's prescision = 3
    r_ids = Resource.active.left_outer_joins(:payloads).where(usages: { period_start: period_start, period_end: period_end.change(usec: 999_000) }).ids
    Resource.active.where.not(id: r_ids).find_each do |res|
      fake_event.type = [res.kind, 'Event'].join('')
      if Services::Payloads::Create.new(res, fake_event, billing_period: [period_start, period_end]).call # check: save method inside. Cause save retuns record.
        payloads_created_count += 1
      else
        $hourly_reports_log.info "FAILED: resource_id = #{res.id}"
      end
    end

    task_end_time = Time.current
    task_duration = task_end_time - task_start_time
    $hourly_reports_log.info "=== Task finished at #{task_end_time}. #{payloads_created_count} payloads created. It took #{task_duration} seconds. ==="
  end
end
