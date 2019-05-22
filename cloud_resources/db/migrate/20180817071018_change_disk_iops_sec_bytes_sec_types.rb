class ChangeDiskIopsSecBytesSecTypes < ActiveRecord::Migration[5.1]
  def change
    change_column :disks, :iops_sec,  :integer, using: 'iops_sec::integer'
    change_column :disks, :bytes_sec, :integer, using: 'bytes_sec::integer'
  end
end
