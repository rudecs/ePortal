class AddBonusBalanceToClients < ActiveRecord::Migration[5.1]
  def up
    add_column :clients, :current_bonus_balance_cents, :integer, null: false, default: 0
    execute <<-SQL
      ALTER TABLE clients
        ADD CONSTRAINT cbbc_chk
        CHECK (current_bonus_balance_cents >= 0);
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE clients
        DROP CONSTRAINT cbbc_chk
    SQL
    remove_column :clients, :current_bonus_balance_cents
  end
end
