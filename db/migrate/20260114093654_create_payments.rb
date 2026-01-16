class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.references :user
      t.references :order
      
      t.string :fincode_order_id
      t.string :fincode_access_id, null: false
      t.string :fincode_transaction_id
      
      t.integer :amount, null: false
      t.integer :tax, default: 0
      t.string :status, default: 'pending', null: false
      t.integer :capture_amount
      t.string :customer_email
      
      t.datetime :authorized_at
      t.datetime :captured_at
      t.datetime :canceled_at
      
      t.text :error_message

      t.timestamps
    end
  end
end
