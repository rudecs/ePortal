class AddLangToBillingCodeVersion < ActiveRecord::Migration[5.1]
  def change
    add_column :billing_code_versions, :lang, :string, null: false
  end
end
