# frozen_string_literal: true

class ClientsDbBase < ApplicationRecord
  self.abstract_class = true
  establish_connection CLIENTS_DB

  # def self.table_name_prefix
  #   "#{CLIENTS_DB['database']}."
  # end
end
