class AddSessionNameToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_column :appointments, :session_name, :string
  end
end
