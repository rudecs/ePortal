module Charge
  class Base < ApplicationRecord
    self.table_name = 'charges'.freeze
  end
end
