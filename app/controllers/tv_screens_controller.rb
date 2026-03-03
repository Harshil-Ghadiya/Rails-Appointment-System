class TvScreensController < ApplicationController
    before_action :authenticate_user!
  layout "application" 

def show
    @organization = Organization.find(params[:id])
    current_time = Time.zone.now
    day_name = current_time.strftime("%A")
    @booking_control = @organization.booking_controls.find_by(day_name: day_name)

    if @booking_control.present?
      current_time_str = current_time.strftime("%H:%M")
      evening_start = @booking_control.evening_start_time.strftime("%H:%M")
      
      if current_time_str < evening_start
        @current_session = "Morning"
      else
        @current_session = "Evening"
      end
    else
      @current_session = "Morning"
    end
  end 
end