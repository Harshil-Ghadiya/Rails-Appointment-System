class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def index 
    @organization = current_user.organization
    
    # Solved: Range used instead of all_day method to avoid ArgumentError
    today_range = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
    @appointments = @organization.appointments.where(created_at: today_range).order(:token_number_only)    

    @booking_url = "#{request.base_url}/appointments/new?org_id=#{@organization.id}" 

    @qrcode = RQRCode::QRCode.new(@booking_url)
    @svg = @qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 3,
      standalone: true,
      use_path: true
    )
  end

  def toggle_booking 
    current_user.organization.toggle!(:is_booking_stopped)
    redirect_to admin_dashboard_path, notice: "Booking Status Changed!"
  end

  def update_doctor_status 
    current_user.organization.update(doctor_status: params[:status])
    redirect_to admin_dashboard_path, notice: "Doctor is now #{params[:status]}"
  end

  def update_status
    appt = current_user.organization.appointments.find(params[:id])
    if appt.update(status: params[:status])
      redirect_to admin_dashboard_path, notice: "Appointment #{params[:status].capitalize}"
    else
      redirect_to admin_dashboard_path, alert: "Failed to update status."
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