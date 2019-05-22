class RenameBillingCodeVersionsToCharges < ActiveRecord::Migration[5.1]
  def change
    rename_column :charges, :billing_code_versions_id, :billing_code_version_id
  end
end
