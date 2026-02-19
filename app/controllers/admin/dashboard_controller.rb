class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def index 
    @organization = current_user.organization


@booking_url = "#{request.base_url}/appointments/new?org_id=#{@organization.id}" 

@qrcode = RQRCode::QRCode.new(@booking_url)
    @svg = @qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 6,
      standalone: true,
      use_path: true
    )
   end
   private 
   def ensure_admin
    unless current_user.has_role?(:admin)
      flash[:alert] = "Access Denied! You are not authorized."
      redirect_to root_path
    end
  end
end
