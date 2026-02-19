class AddDoctorStatusToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :doctor_status, :string
  end
end
