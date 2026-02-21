class AddAddressToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_column :appointments, :patient_address, :string
  end
end
