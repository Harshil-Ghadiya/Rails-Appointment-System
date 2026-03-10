class Admin::BookingControlsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def index
    @organization = current_user.organization
    @booking_controls = @organization.booking_controls.includes(:booking_slots)
    
    if @booking_controls.empty?
      ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].each do |day|
        @organization.booking_controls.create(
          day_name: day, 
          token_prefix: 'T')
ctrl.booking_slots.create(start_time: '09:00', end_time: '18:00')     
   
      end 
      @booking_controls = @organization.booking_controls.reload
    end
  end

  def update
    @control = current_user.organization.booking_controls.find(params[:id])
    @booking_controls = current_user.organization.booking_controls
    
if @control.update(booking_control_params)
      flash.now[:notice] = "Booking slots for #{@control.day_name} updated!"
      
      @booking_controls = current_user.organization.booking_controls.includes(:booking_slots)
      @booking_controls.each { |ctrl| ctrl.booking_slots.build }

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend("flash-container", partial: "layouts/flash"),
            turbo_stream.replace("booking_schedule_container", 
                                 partial: "admin/booking_controls/schedule_table", 
                                 locals: { booking_controls: @booking_controls })
          ]
        end
        format.html { redirect_to admin_booking_controls_path }
      end
    end
  end

  private


def booking_control_params
    params.require(:booking_control).permit(
      :token_prefix, 
      booking_slots_attributes: [:id, :start_time, :end_time, :_destroy]
    )
  end

  def ensure_admin
    unless current_user.has_role?(:admin)
      flash[:alert] = "Access Denied!"
      redirect_to root_path
    end
  end
end