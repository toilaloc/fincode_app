class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :user
      t.references :product
      t.string :number, null: false, index: { unique: true }
      t.integer :quantity, null: false, default: 1
      t.decimal :total_amount, precision: 15, scale: 2, null: false
      t.string :status, default: 'pending'

      t.timestamps
    end
  end
end
