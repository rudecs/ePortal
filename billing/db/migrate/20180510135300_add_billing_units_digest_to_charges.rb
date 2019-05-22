class AddBillingUnitsDigestToCharges < ActiveRecord::Migration[5.1]
  def change
    change_table :charges do |t|
      t.string :billing_units_digest, null: false
      t.references :product_instance, null: false
      t.references :billing_code_versions
      t.index :billing_units_digest
    end
  end
end
