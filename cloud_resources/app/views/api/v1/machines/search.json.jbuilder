json.machines @machines do |machine|
  json.partial! 'machines/machine.json', machine: machine
end
