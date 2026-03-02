class Admin::AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def index
    @organization = current_user.organization
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

      @appointments = @organization.appointments
                                   .where(created_at: current_time.all_day)
                                   .where(session_name: @current_session)
                                   .order(:token_number_only)
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