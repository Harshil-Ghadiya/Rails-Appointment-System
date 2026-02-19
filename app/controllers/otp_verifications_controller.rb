class OtpVerificationsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(id: session[:otp_user_id])

    if user && params[:otp] == user.otp_code
      sign_in(:user, user)
   user.update(otp_code: nil) 

if user.has_role?(:superadmin)
  redirect_to superadmin_dashboard_path, notice: "Welcome Super Admin! Enter your Dashboard."
elsif user.has_role?(:admin)
  redirect_to admin_dashboard_path, notice: "Welcome Admin! Enter your Dashboard."
else
  redirect_to new_user_session_path, notice: "Logged in successfully!"
end

    else
      flash[:alert] = "Invalid OTP, try again."
      render :new
    end
  end
end
