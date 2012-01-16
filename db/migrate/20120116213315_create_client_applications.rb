class CreateClientApplications < ActiveRecord::Migration
  def change
    create_table :client_applications do |t|
      t.string :public_key, :limit => 16
      t.string :secret_key

      t.timestamps
    end

    add_index :client_applications, :public_key, :unique => true
  end
end
