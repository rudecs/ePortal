class ExecutePlaybookJob < ApplicationJob
  queue_as :playbooks

  def perform(playbook_id)
    playbook = ::Playbook.find(playbook_id)
    playbook.execute
  end
end
