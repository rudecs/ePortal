class ChangeDisksSize < ActiveRecord::Migration[5.1]
  def change
    change_column :disks, :size, :integer, using: 'size::integer'
  end
end
