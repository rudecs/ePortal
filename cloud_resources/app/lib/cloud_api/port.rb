class CloudAPI::Port < CloudAPI::Base
  STRUCT_FIELDS = [
    :id, :machineId, :machineName, :protocol, :localIp, :localPort,
    :publicIp, :publicPort
  ]

  def list(cloud_space_id, machine_id=nil)
    self.authenticate
    url = "/restmachine/cloudapi/portforwarding/list"
    res = @conn.post(url) do |req|
      req.body = {
        cloudspaceId: cloud_space_id,
        machineId: machine_id,
      }.to_json
    end
    self.parse_response(res).map do |data|
      self.create_struct(data)
    end
  end

  def create(cloudspaceId:, machineId:, publicIp:, publicPort:, localPort:, protocol:)
    self.authenticate
    url = "/restmachine/cloudapi/portforwarding/create"
    res = @conn.post(url) do |req|
      req.body = {
        cloudspaceId: cloudspaceId,
        machineId: machineId,
        publicIp: publicIp,
        publicPort: publicPort,
        localPort: localPort,
        protocol: protocol,
      }.to_json
    end
    self.parse_response(res)
    self.list(cloudspaceId, machineId).map do |port|
      if protocol == port.protocol && publicPort.to_s == port.publicPort && localPort.to_s == port.localPort
        return port
      end
    end
  end

  def update(id:, cloudspaceId:, machineId:, publicIp:, publicPort:, localPort:, protocol:)
    self.authenticate
    url = "/restmachine/cloudapi/portforwarding/update"
    res = @conn.post(url) do |req|
      req.body = {
        id: id,
        cloudspaceId: cloudspaceId,
        machineId: machineId,
        publicIp: publicIp,
        publicPort: publicPort,
        localPort: localPort,
        protocol: protocol,
      }.to_json
    end
    self.parse_response(res).map do |port|
      port = self.create_struct(port)
      if protocol == port.protocol && publicPort.to_s == port.publicPort && localPort.to_s == port.localPort
        return port
      end
    end
  end

  def delete(cloudspaceId:, publicIp:, publicPort:, proto:)
    self.authenticate
    url = "/restmachine/cloudapi/portforwarding/deleteByPort"
    res = @conn.post(url) do |req|
      req.body = {
        cloudspaceId: cloudspaceId,
        publicIp: publicIp,
        publicPort: publicPort,
        proto: proto,
      }.to_json
    end
    self.parse_response(res)
    return true
  end

  protected
end
