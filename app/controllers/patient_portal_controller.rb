# app/controllers/patient_portal_controller.rb
class PatientPortalController < ApplicationController

  # Aa page login vagar khulvu joie
  skip_before_action :authenticate_user!, only: [:show_info], raise: false 
before_action :check_org_status, only: [:show_info]

  def show_info
    @organization = Organization.find(params[:id])
    @current_token = @organization.appointments.where(status: 'pending', created_at: Time.zone.now.all_day).minimum(:token_number) || 0
    @last_token = @organization.appointments.where(created_at: Time.zone.now.all_day).maximum(:token_number) || 0
  end

  def check_org_status
  @appointment = Appointment.find_by(id: params[:id])
  if @appointment && !@appointment.organization.is_approved
    render plain: "This organization is currently inactive.", status: :forbidden
  end
end
end