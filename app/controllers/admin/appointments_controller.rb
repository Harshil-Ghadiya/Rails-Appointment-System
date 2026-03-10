class Admin::AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def index
    @organization = current_user.organization
    current_time = Time.zone.now
    day_name = current_time.strftime("%A")
    @booking_control = @organization.booking_controls.find_by(day_name: day_name)

    if @booking_control.present?
      now_str = current_time.strftime("%H:%M")
      
      active_slot = @booking_control.booking_slots
                                    .where("strftime('%H:%M', start_time) <= ? AND strftime('%H:%M', end_time) >= ?", now_str, now_str)
                                    .first


   if active_slot.present?

@current_session = "Slot-#{active_slot.id}"

      @appointments = @organization.appointments
                                   .where(created_at: current_time.all_day)
                                   .where(session_name: @current_session)
                                   .order(:token_number_only)
else
        @appointments = []
        @current_session = "No Active Slot"
      end
      
    else
      @appointments = []
    end

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("appointments_list", 
                 partial: "admin/appointments/table", 
                 locals: { appointments: @appointments })
      end
    end
  end

  private

  def ensure_admin
    unless current_user.has_role?(:admin)
      flash[:alert] = "Access Denied! You are not authorized."
      redirect_to root_path
    end
  end
end