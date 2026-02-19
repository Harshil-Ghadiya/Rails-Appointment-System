class AddTokenNumberOnlyToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_column :appointments, :token_number_only, :integer
    add_index :appointments, :token_number_only
  end
end
