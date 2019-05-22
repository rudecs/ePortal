class Client::UnblockJob < ApplicationJob
  def perform(client_id)
    # client = Client.find(client_id)
    # check balance && status
    # Services::Clients::Blocker.new(client).unblock!
  end
end
