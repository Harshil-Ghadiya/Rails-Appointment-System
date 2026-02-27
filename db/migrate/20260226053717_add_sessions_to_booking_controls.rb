class AddSessionsToBookingControls < ActiveRecord::Migration[8.1]
  def change
    add_column :booking_controls, :morning_start_time, :time
    add_column :booking_controls, :morning_end_time, :time
    add_column :booking_controls, :evening_start_time, :time
    add_column :booking_controls, :evening_end_time, :time
  end
end
