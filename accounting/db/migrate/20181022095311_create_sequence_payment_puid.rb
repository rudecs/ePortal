class CreateSequencePaymentPuid < ActiveRecord::Migration[5.2]
  def change
    execute('CREATE SEQUENCE IF NOT EXISTS admin_payment_puid_sequence')
  end
end
