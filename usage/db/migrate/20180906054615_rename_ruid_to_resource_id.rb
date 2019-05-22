class RenameRuidToResourceId < ActiveRecord::Migration[5.2]
  def change
    remove_index  :resources, :ruid # rename_index(table_name, old_name, new_name)?!
    rename_column :resources, :ruid, :resource_id
    add_index     :resources, :resource_id, unique: true
  end
end
