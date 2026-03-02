class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def index 
    @organization = current_user.organization


    
    # Solved: Range used instead of all_day method to avoid ArgumentError
    today_range = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
    @appointments = @organization.appointments.where(created_at: today_range).order(:token_number_only)  
    respond_to do |format|
format.html { render layout: !turbo_frame_request? } 
  end 
  end

  def generate_qr
    @organization = current_user.organization
    @booking_url = "#{request.base_url}/appointments/new?org_id=#{@organization.id}" 
    
    @qrcode = RQRCode::QRCode.new(@booking_url)
    @svg = @qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 4, # Thodo moto QR jethi scan ma easy rahe
      standalone: true,
      use_path: true
    )
  end

def toggle_booking 
    @organization = current_user.organization
    @organization.toggle!(:is_booking_stopped)
    
    # LIVE TOAST MATE: flash.now vapray turbo stream ma
    flash.now[:notice] = @organization.is_booking_stopped ? "Booking Stopped!" : "Booking Started!"

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          # 1. Toast Message trigger karo
          turbo_stream.prepend("flash-container", partial: "layouts/flash"),
          # 2. Content update karo (Replace button/status area)
          turbo_stream.replace("booking_status_area", partial: "admin/dashboard/booking_status_toggle")
        ]
      end
      format.html { redirect_to admin_dashboard_path, notice: flash.now[:notice] }
    end
  end

  # DOCTOR STATUS 
  def update_doctor_status 
    @organization = current_user.organization
    @organization.update(doctor_status: params[:status])
    
    flash.now[:notice] = "Doctor is now #{params[:status].capitalize}"

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.prepend("flash-container", partial: "layouts/flash"),
          turbo_stream.replace("doctor_status_area", partial: "admin/dashboard/doctor_status_display")
        ]
      end
      format.html { redirect_to admin_dashboard_path, notice: flash.now[:notice] }
    end
  end


def update_status
  @appointment = current_user.organization.appointments.find(params[:id])
  
  if @appointment.update(status: params[:status])

    flash.now[:notice] = "Token #{@appointment.token_number} moved to #{params[:status].capitalize}!"

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.prepend("flash-container", partial: "layouts/flash"),
          
          turbo_stream.remove("appt_row_#{@appointment.id}"),
          
          turbo_stream.append("#{params[:status]}_appointments", 
                               partial: "admin/dashboard/appointment_row", 
                               locals: { appt: @appointment })
        ]
      end
      format.html { redirect_to admin_dashboard_path, notice: "Status updated!" }
    end
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