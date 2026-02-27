class Admin::AppointmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def index
    @organization = current_user.organization
    
    # 1. Get current day control to find your SET timing
    day_name = Time.zone.now.strftime("%A")
    @booking_control = @organization.booking_controls.find_by(day_name: day_name)

    if @booking_control.present?
      current_time_str = Time.zone.now.strftime("%H:%M")
      
      # 2. Dynamic Session Logic: Tame set karela Evening start time mujab switch thase
      evening_start = @booking_control.evening_start_time.strftime("%H:%M")
      
      if current_time_str < evening_start
        @current_session = "Morning"
      else
        @current_session = "Evening"
      end

      # 3. Filter Appointments: Khali AAJNA ane CURRENT SESSION na j tokens
      @appointments = @organization.appointments
                                   .where(created_at: Time.zone.now.all_day)
                                   .where(session_name: @current_session)
                                   .order(:token_number_only)
    else
      @appointments = []
    end

    respond_to do |format|
      format.html
      # Jo tame automatic refresh (Turbo Stream) use karta hov to aa kaam lagshe
      format.turbo_stream { render turbo_stream: turbo_stream.replace("appointments_list", partial: "admin/appointments/table") }
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