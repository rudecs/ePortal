class Playbooks::Sync::Base
  SCHEMA_RESOURCE_STATES_MAPPING = [
    %w(active nil),
    %w(active active),
    %w(active deleted),
    %w(active failed),
    %w(active processing),
    %w(deleted nil),
    %w(deleted active),
    %w(deleted deleted),
    %w(deleted failed),
    %w(deleted processing),
  ]

  attr_accessor :schema, :resource

  def initialize(schema, resource)
    @schema = schema.symbolize_keys
    @resource = resource
  end

  def process_resource
    @resource.process
  end

  def sync
    schema_state = @schema[:state]
    resource_state = @resource.try(:state)
    resource_state = 'nil' unless resource_state.present?
    unless SCHEMA_RESOURCE_STATES_MAPPING.include?([schema_state, resource_state])
      return false
    end

    if @schema[:name].present? && @resource.present? && defined?(@resource.name) && @schema[:name] != @resource.name
      @resource.update_attributes(name: @schema[:name])
    end

    fn_name = "sync_#{schema_state}_#{resource_state}"
    return self.send(fn_name)
  end

  def sync_active_nil
    raise NotImplementedError
  end

  def sync_active_active
    return true
  end

  # ошибка: нельзя сделать активным удаленный resource
  def sync_active_deleted
    return false
  end

  # resource сломан, нужно попытаться починить,
  # иначе - вернуть ошибку
  def sync_active_failed
    return false
  end

  # завершить текущую операцию над resource,
  # затем начать сначала
  def sync_active_processing
    self.process_resource
    return self.sync
  end

  # ошибка: нельзя удалить несуществующее
  def sync_deleted_nil
    return false
  end

  # удалить resource
  def sync_deleted_active
    @resource.delete
    return self.sync
  end

  def sync_deleted_deleted
    return true
  end

  # попытаться удалить сломанный resource,
  # иначе - вернуть ошибку
  def sync_deleted_failed
    return false
  end

  # завершить текущую операцию над resource
  # затем начать сначала
  def sync_deleted_processing
    self.process_resource
    return self.sync
  end

end
