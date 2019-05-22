class AddGatewayToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :gateway, :string #, null: false, default: 'payu'
  end
end
