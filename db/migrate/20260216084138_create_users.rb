class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :phone_number
      t.text :address
      t.string :password_digest
      t.integer :organization_id
      t.timestamps
    end
  end
end
