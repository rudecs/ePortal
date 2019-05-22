class CreateSequenceResourceId < ActiveRecord::Migration[5.1]
  def change
    execute('CREATE SEQUENCE IF NOT EXISTS resource_id_sequence')
  end
end
