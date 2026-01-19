class AddRefundedAtToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :refunded_at, :datetime
  end
end
