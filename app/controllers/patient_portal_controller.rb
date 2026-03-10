class PatientPortalController < ApplicationController

skip_before_action :authenticate_user!, only: [:show_info], raise: false 
before_action :check_org_status, only: [:show_info]

def show_info
  @organization = Organization.find(params[:id])
  current_time = Time.zone.now
  day_name = current_time.strftime("%A")
  control = @organization.booking_controls.find_by(day_name: day_name)

now_str = current_time.strftime("%H:%M")
    active_slot = control&.booking_slots
                         &.where("strftime('%H:%M', start_time) <= ? AND strftime('%H:%M', end_time) >= ?", 
                                 now_str, now_str)&.first

    if active_slot.present?
      @session_label = "Slot-#{active_slot.id}"
      prefix = control.token_prefix || "T"
    else
      # Jo break time hoy to empty label
      @session_label = "No-Active-Slot"
      prefix = control&.token_prefix || "T"
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
                                   .where.not(status: :deleted)
                            .maximum(:token_number_only)
  
  @last_token = max_booked ? "T-#{max_booked}" : "0"
end


private 

  def check_org_status
  @appointment = Appointment.find_by(id: params[:id])
  if @appointment && !@appointment.organization.is_approved
    render plain: "This organization is currently inactive.", status: :forbidden
  end
end
end

