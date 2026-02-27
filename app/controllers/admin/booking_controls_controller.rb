class Admin::BookingControlsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin
  def index
    @organization = current_user.organization
    @booking_controls = @organization.booking_controls
    
    if @booking_controls.empty?
      ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].each do |day|
        @organization.booking_controls.create(day_name: day, token_prefix: 'T', morning_start_time: '10:00', morning_end_time: '12:00',
          evening_start_time: '14:00', evening_end_time: '16:00')

      end 
      @booking_controls = @organization.booking_controls.reload
    end
  end

def update
  @control = current_user.organization.booking_controls.find(params[:id])
  
  if @control.update(params.require(:booking_control).permit(:token_prefix, :morning_start_time, :morning_end_time, :evening_start_time, :evening_end_time))
    
    flash.now[:notice] = "Booking time for #{@control.day_name} updated!"

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.prepend("flash-container", partial: "layouts/flash"),
          turbo_stream.replace("booking_row_#{@control.id}", partial: "admin/booking_controls/booking_row", locals: { control: @control })
        ]
      end
      format.html { redirect_to admin_booking_controls_path, notice: flash.now[:notice] }
    end
  end
end



      def ensure_admin
    unless current_user.has_role?(:admin)
      flash[:alert] = "Access Denied! You are not authorized."
      redirect_to root_path
    end
  end
end



