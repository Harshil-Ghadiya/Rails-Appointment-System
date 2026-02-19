class Admin::BookingControlsController < ApplicationController
  def index
    @organization = current_user.organization
    @booking_controls = @organization.booking_controls
    
    if @booking_controls.empty?
      ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].each do |day|
        @organization.booking_controls.create(day_name: day, token_prefix: 'T', start_time: '10:00', end_time: '15:00')
      end
      @booking_controls = @organization.booking_controls.reload
    end
  end

  def update
    @control = current_user.organization.booking_controls.find(params[:id])
    if @control.update(params.require(:booking_control).permit(:token_prefix, :start_time, :end_time))
      redirect_to admin_booking_controls_path, notice: "Booking time for #{@control.day_name} updated!"
    end
  end
end