class CreateBookingSlots < ActiveRecord::Migration[8.1]
  def change
    create_table :booking_slots do |t|
      t.references :booking_control, null: false, foreign_key: true
      t.time :start_time
      t.time :end_time
      t.string :slot_name

      t.timestamps
    end
  end
end
