class OtpVerificationsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(id: session[:otp_user_id])
    phone = session[:otp_phone] 

    if user && params[:otp].present?
      if TwilioService.check_otp(phone, params[:otp])
        sign_in(:user, user)
        
        session.delete(:otp_user_id)
        session.delete(:otp_phone)

        if user.has_role?(:superadmin)
          redirect_to superadmin_dashboard_path, notice: "Welcome Super Admin!"
        elsif user.has_role?(:admin)
          redirect_to admin_dashboard_path, notice: "Welcome Admin!"
        else
          redirect_to root_path, notice: "Logged in successfully!"
        end
      else
        flash.now[:alert] = "Invalid OTP, please try again."
        render :new
      end
    else
      flash[:alert] = "Invalid request or session expired."
      redirect_to new_user_session_path
    end
  end
end