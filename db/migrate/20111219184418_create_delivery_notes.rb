class CreateDeliveryNotes < ActiveRecord::Migration
  def change
    create_table :delivery_notes do |t|
      t.integer :product_id
      t.integer :amount
      t.integer :customer_id

      t.timestamps
    end
  end
end
