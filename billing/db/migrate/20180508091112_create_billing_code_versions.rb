class CreateBillingCodeVersions < ActiveRecord::Migration[5.1]
  def change
    create_table :billing_code_versions do |t|
      t.references :product_instance, foreign_key: true
      t.text :code, null: false

      t.timestamps
    end
  end
end
