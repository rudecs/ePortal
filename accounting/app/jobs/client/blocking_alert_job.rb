class Client::BlockingAlertJob < ApplicationJob
  def perform
    Services::Clients::BlockingAlert.new(Time.current).call
  end
end
