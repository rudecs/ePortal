class AddTimeSequenceToCharges < ActiveRecord::Migration[5.1]
  def change
    change_table :charges do |t|
      t.string :time_sequence_uid
      t.index :time_sequence_uid
    end
  end
end
