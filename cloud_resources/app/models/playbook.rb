class Playbook < ApplicationRecord
  STATES = %w(
    pending deploying deployed failed
  )

  # #############################################################
  # Associations

  # has_many :disks
  # has_many :images
  # has_many :cloud_spaces
  # has_many :machines
  # has_many :ports


  # #############################################################
  # Validations

  validates :schema, presence: true
  validates :state,  presence: true, inclusion: { in: STATES    }


  # #############################################################
  # Callbacks


  # #############################################################
  # Scopes


  # #############################################################
  # Class methods


  # #############################################################
  # Instance methods

  def execute
    return false if self.state == 'deploying'
    return false if self.state == 'deployed'
    Playbooks::Executor.new(self).run
  end

end
