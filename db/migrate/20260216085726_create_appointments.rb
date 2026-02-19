class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.integer :organization_id
      t.string :patient_name
      t.string :patient_email
      t.string :patient_phone
      t.string :token_number
      t.integer :status
      t.timestamps
    end
  end
end
