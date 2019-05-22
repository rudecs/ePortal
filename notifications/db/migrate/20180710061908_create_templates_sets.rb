class CreateTemplatesSets < ActiveRecord::Migration[5.2]
  def change
    create_table :templates_sets do |t|
      t.string :key_name, null: :false
      t.string :category

      t.timestamps
    end
    add_index :templates_sets, :key_name, unique: true
  end
end
