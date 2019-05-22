class Playbooks::Executor
  attr_reader :playbook

  def initialize(playbook)
    playbook = Playbook.find(playbook) if playbook.class == Integer
    @playbook = playbook
  end

  def run
    @playbook.update_attributes({
      state: 'deploying',
      error_messages: [],
    })

    active_cloud_spaces_elements = []
    active_machines_elements = []
    active_ports_elements = []
    active_disks_elements = []
    active_snapshots_elements = []
    deleted_cloud_spaces_elements = []
    deleted_machines_elements = []
    deleted_ports_elements = []
    deleted_disks_elements = []
    deleted_snapshots_elements = []

    self.playbook_schema.each do |ele|
      active_cloud_spaces_elements << ele if ele['state'] == 'active' && ele['type'] == 'cloud_space'
      active_machines_elements << ele if ele['state'] == 'active' && ele['type'] == 'machine'
      active_ports_elements << ele if ele['state'] == 'active' && ele['type'] == 'port'
      active_disks_elements << ele if ele['state'] == 'active' && ele['type'] == 'disk'
      active_snapshots_elements << ele if ele['state'] == 'active' && ele['type'] == 'snapshot'
      deleted_cloud_spaces_elements << ele if ele['state'] == 'deleted' && ele['type'] == 'cloud_space'
      deleted_machines_elements << ele if ele['state'] == 'deleted' && ele['type'] == 'machine'
      deleted_ports_elements << ele if ele['state'] == 'deleted' && ele['type'] == 'port'
      deleted_disks_elements << ele if ele['state'] == 'deleted' && ele['type'] == 'disk'
      deleted_snapshots_elements << ele if ele['state'] == 'deleted' && ele['type'] == 'snapshot'
    end

    [
      deleted_snapshots_elements,
      deleted_disks_elements,
      deleted_ports_elements,
      deleted_machines_elements,
      deleted_cloud_spaces_elements,
      active_cloud_spaces_elements,
      active_machines_elements,
      active_disks_elements,
      active_snapshots_elements,
      active_ports_elements,
    ].each do |elements|
      elements.each do |ele|
        unless self.sync(ele)
          return @playbook.update_attributes({
            state: 'failed',
          })
        end
      end
    end

    @playbook.update_attributes({
      state: 'deployed',
    })

    rescue => err

    @playbook.update_attributes({
      state: 'failed',
      error_messages: [
        {
          message: err.message,
          backtrace: err.backtrace,
        },
      ],
    })
  end

  def playbook
    return @playbook if defined?(@playbook)
    @playbook = Playbook.find(params[:playbook][:id])
  end

  def playbook_schema
    self.playbook.schema || []
  end

  # TODO: refactor
  def resources_dict
    return @resources_dict if defined?(@resources_dict)
    @resources_dict = {}

    cloud_space_ids = []
    machine_ids = []
    port_ids = []
    disk_ids = []
    snapshot_ids = []

    self.playbook_schema.each do |ele|
      if ele['type'] == 'cloud_space'
        cloud_space_ids.push(ele['id'])
      elsif ele['type'] == 'machine'
        machine_ids.push(ele['id'])
      elsif ele['type'] == 'port'
        port_ids.push(ele['id'])
      elsif ele['type'] == 'disk'
        disk_ids.push(ele['id'])
      elsif ele['type'] == 'snapshot'
        snapshot_ids.push(ele['id'])
      end
    end

    CloudSpace.where(id: cloud_space_ids).find_each do |cloud_space|
      @resources_dict[cloud_space.id] = cloud_space
    end

    Machine.where(id: machine_ids).find_each do |machine|
      @resources_dict[machine.id] = machine
    end

    Port.where(id: port_ids).find_each do |port|
      @resources_dict[port.id] = port
    end

    Disk.where(id: disk_ids).find_each do |disk|
      @resources_dict[disk.id] = disk
    end

    Snapshot.where(id: snapshot_ids).find_each do |snapshot|
      @resources_dict[snapshot.id] = snapshot
    end

    @resources_dict
  end

  def schema_dict
    return @schema_dict if defined?(@schema_dict)
    @schema_dict = {}

    self.playbook_schema.each do |ele|
      @schema_dict[ele['id']] = ele
    end

    @schema_dict
  end

  def sync(schema_element)
    self.send(['sync', schema_element['type']].join('_'), schema_element) if %w[cloud_space machine port snapshot disk].include? schema_element['type']
  end

  def sync_cloud_space(schema_element)
    cloud_space = self.resources_dict[schema_element['id']]
    synchronizer = Playbooks::Sync::CloudSpace.new(schema_element, cloud_space)
    resp = synchronizer.sync
    if synchronizer.resource.present?
      self.resources_dict[synchronizer.resource.id] = synchronizer.resource
    end
    resp
  end

  def sync_machine(schema_element)
    machine = self.resources_dict[schema_element['id']]
    synchronizer = Playbooks::Sync::Machine.new(schema_element, machine)
    resp = synchronizer.sync
    if synchronizer.resource.present?
      self.resources_dict[synchronizer.resource.id] = synchronizer.resource
    end
    resp
  end

  def sync_port(schema_element)
    port = self.resources_dict[schema_element['id']]
    synchronizer = Playbooks::Sync::Port.new(schema_element, port)
    resp = synchronizer.sync
    if synchronizer.resource.present?
      self.resources_dict[synchronizer.resource.id] = synchronizer.resource
    end
    resp
  end

  def sync_snapshot(schema_element)
    snapshot = self.resources_dict[schema_element['id']]
    synchronizer = Playbooks::Sync::Snapshot.new(schema_element, snapshot)
    resp = synchronizer.sync
    if synchronizer.resource.present?
      self.resources_dict[synchronizer.resource.id] = synchronizer.resource
    end
    resp
  end

  def sync_disk(schema_element)
    disk = self.resources_dict[schema_element['id']]
    synchronizer = Playbooks::Sync::Disk.new(schema_element, disk)
    resp = synchronizer.sync
    if synchronizer.resource.present?
      self.resources_dict[synchronizer.resource.id] = synchronizer.resource
    end
    resp
  end
end
