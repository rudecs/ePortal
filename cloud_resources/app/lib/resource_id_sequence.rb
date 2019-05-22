class ResourceIdSequence
  def self.nextval
    query = "SELECT nextval('resource_id_sequence')"
    id = ActiveRecord::Base.connection.exec_query(query)[0]['nextval']

    # полученный аудишник будет использоваться в том числе в качестве имени в облаке
    # у некоторых ресурсов имя должно быть не короче двух (cloud_space) и трех (machine) символов
    return self.nextval if id < 100

    id
  end

  def self.last_value
    query = "SELECT last_value FROM resource_id_sequence"
    ActiveRecord::Base.connection.exec_query(query)[0]['last_value']
  end
end
