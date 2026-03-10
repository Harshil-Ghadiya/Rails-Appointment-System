class TvScreensController < ApplicationController
    before_action :authenticate_user!
  layout "application" 

def show
    @organization = Organization.find(params[:id])
    current_time = Time.zone.now
    day_name = current_time.strftime("%A")
    @booking_control = @organization.booking_controls.find_by(day_name: day_name)
if @booking_control.present?

now_str = current_time.strftime("%H:%M")
      active_slot = @booking_control.booking_slots
                                    .where("strftime('%H:%M', start_time) <= ? AND strftime('%H:%M', end_time) >= ?", 
                                           now_str, now_str).first

      if active_slot.present?
        # Unique Session ID set karo
        @current_session = "Slot-#{active_slot.id}"
      else
        # Jo break time hoy
        @current_session = "No Active Slot"
      end
    else
      @current_session = "Default"
    end

  end
end

