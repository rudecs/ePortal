class CreateTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :templates do |t|
      t.integer  :templates_set_id, null: false
      t.text     :content, null: false
      t.string   :locale, null: false
      # REVIEW: move to teplates_sets?
      # t.string :delivery_methods, array: true, default: []
      t.integer  :delivery_method, null: false
      t.string   :subject

      t.timestamps
    end
    add_index :templates, :templates_set_id
    add_index :templates, [:templates_set_id, :locale, :delivery_method], unique: true, name: 'templates_set_locale_delivery'
  end
end
