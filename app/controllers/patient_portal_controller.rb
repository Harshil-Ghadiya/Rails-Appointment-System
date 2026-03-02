class PatientPortalController < ApplicationController

  skip_before_action :authenticate_user!, only: [:show_info], raise: false 
before_action :check_org_status, only: [:show_info]

def show_info
  @organization = Organization.find(params[:id])
  current_time = Time.zone.now
  day_name = current_time.strftime("%A")
  control = @organization.booking_controls.find_by(day_name: day_name)

  if control.present?
    current_time_str = current_time.strftime("%H:%M")
    e_start = control.evening_start_time.strftime("%H:%M")
    @session_label = current_time_str < e_start ? "Morning" : "Evening"
  else
    @session_label = "Morning"
  end

  
  min_pending = @organization.appointments
                             .where(created_at: current_time.all_day, 
                                    session_name: @session_label, 
                                    status: :pending)
                             .minimum(:token_number_only)
  
  @current_token = min_pending ? "T-#{min_pending}" : "0"

  max_booked = @organization.appointments
                            .where(created_at: current_time.all_day, 
                                   session_name: @session_label)
                            .maximum(:token_number_only)
  
  @last_token = max_booked ? "T-#{max_booked}" : "0"
end

  def check_org_status
  @appointment = Appointment.find_by(id: params[:id])
  if @appointment && !@appointment.organization.is_approved
    render plain: "This organization is currently inactive.", status: :forbidden
  end
end
end