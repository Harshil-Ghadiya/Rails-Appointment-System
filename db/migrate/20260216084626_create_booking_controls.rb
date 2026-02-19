class CreateBookingControls < ActiveRecord::Migration[8.1]
  def change
    create_table :booking_controls do |t|
      t.integer :organization_id
      t.string :day_name
      t.string :token_prefix
      t.time :start_time
      t.time :end_time
      t.timestamps
    end
  end
end
