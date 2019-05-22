# frozen_string_literal: true

## Критерии поиска Клиентов

#В микросервисе каждлый учетный период 1 час, происходит перебор всех Клиентов. Все клиенты проверяются по следующих параметрам:
#- Тип Клиента ( Prepaid в статусе actice подлежат биллингу каждый учетный период)
#- Время прошедшего с последнего биллинга больше биллингового периода.
namespace :cron do
  desc 'Create empty Writeoffs for clients during billing period'
  task prepare_writeoffs: :environment do
    # log = ActiveSupport::Logger.new('log/cron_prepare_writeoffs.log')
    task_start_time = Time.current
    period_start = task_start_time.beginning_of_hour
    period_end = task_start_time.end_of_hour
    writeoffs_created_count = 0

    log.info "=== Start task at (#{task_start_time}) ==="
    log.info "Billing period: from #{period_start} to #{period_end}."

    # TODO: Client.join(:writeoffs)....
    Client.active.prepaid.or(Client.postpaid_to_writeoff(time)).find_each do |client|
      if Services::Writeoffs::Create.new(client, billing_period: [period_start, period_end]).call
        writeoffs_created_count += 1
      else
        log.info "FAILED: client_id = #{client.id}"
      end
    end

    task_end_time = Time.current
    task_duration = task_end_time - task_start_time
    log.info "=== Task finished at #{task_end_time}. #{writeoffs_created_count} writeoffs created. It took #{task_duration} seconds. ==="
    log.close
  end
end
