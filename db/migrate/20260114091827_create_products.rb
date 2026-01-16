class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.references :user
      t.references :category
      t.string :name, null: false
      t.decimal :price, precision: 16, scale: 2, null: false

      t.timestamps
    end
  end
end
