class Superadmin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_super_admin

    def index 
    @organizations = Organization.all
  end

def approve
    @org = Organization.find(params[:id])
    @org.update(is_approved: true) 
    redirect_to superadmin_dashboard_path, notice: "Organization Approved!"
  end

  def inactive
    @org = Organization.find(params[:id])
    @org.update(is_approved: false) 
    redirect_to superadmin_dashboard_path, alert: "Organization Deactivated!"
  end


def login_as_admin
  @organization = Organization.find(params[:id])
  

  @admin_user = @organization.users.first 

  if @admin_user
    sign_in(:user, @admin_user)
    
    session[:is_impersonating] = true 
    
    redirect_to admin_dashboard_path, notice: "Logged in as Admin for #{@organization.name}"
  else
    redirect_to superadmin_dashboard_path, alert: "No user found for this organization."
  end
end


private

  def ensure_super_admin
    unless current_user.has_role?(:superadmin)
      flash[:alert] = "Access Denied! You are not authorized."
      redirect_to root_path 
    end
  end
end

