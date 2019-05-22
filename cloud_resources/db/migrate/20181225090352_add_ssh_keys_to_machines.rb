class AddSshKeysToMachines < ActiveRecord::Migration[5.1]
  def change
    add_column :machines, :ssh_keys, :string, array: true
  end
end
