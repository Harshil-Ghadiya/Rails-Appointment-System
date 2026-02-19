class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :email
      t.string :phone_number
      t.text :address
      t.boolean :is_approved
      t.boolean :is_booking_stopped
      t.timestamps
    end
  end
end
