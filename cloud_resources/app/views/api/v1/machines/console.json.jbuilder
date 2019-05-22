json.machine do
  json.id           @machine.id
  json.console_url  @console_url
  json.ssh_login    @ssh_login
  json.ssh_password @ssh_password
end
