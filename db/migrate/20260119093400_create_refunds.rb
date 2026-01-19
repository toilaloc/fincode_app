class CreateRefunds < ActiveRecord::Migration[7.0]
  def change
    create_table :refunds do |t|
      t.references :payment, null: false, foreign_key: true
      t.references :processed_by, foreign_key: { to_table: :users }
      
      t.integer :amount, null: false
      t.text :reason
      t.string :status, null: false, default: 'pending'
      t.string :fincode_refund_id
      t.datetime :processed_at
      
      t.timestamps
    end
    
    add_index :refunds, :status
    add_index :refunds, :fincode_refund_id
  end
end
