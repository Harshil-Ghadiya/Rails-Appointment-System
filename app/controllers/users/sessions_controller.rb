class Users::SessionsController < Devise::SessionsController
  skip_before_action :require_no_authentication, only: [:create]

  def create
    user = User.find_by(email: params[:user][:email])
    
    if user.nil?
      flash[:alert] = "Invalid Email."
      return redirect_to new_user_session_path
    end

    if params[:user][:password].present?
      if user.valid_password?(params[:user][:password])
        if check_approval(user)
          sign_in(:user, user)
          return redirect_to after_sign_in_path_for(user), notice: "Logged in successfully!"
        end
      else
        flash[:alert] = "Invalid Password."
        return redirect_to new_user_session_path
      end

    elsif params[:user][:phone_number].present?
      if user.phone_number == params[:user][:phone_number]
        if check_approval(user)
          my_fixed_number = "7383065396" 
          
          begin
            TwilioService.send_otp(my_fixed_number)
            
            session[:otp_user_id] = user.id
            session[:otp_phone] = my_fixed_number
            
            return redirect_to verify_otp_path, notice: "OTP sent to Admin's registered mobile!"
          rescue => e
            flash[:alert] = "Twilio Error: #{e.message}"
            return redirect_to new_user_session_path
          end
        end
      else
        flash[:alert] = "Mobile number does not match with this email."
        return redirect_to new_user_session_path
      end
    else
      flash[:alert] = "Please enter either Password or Mobile Number."
      return redirect_to new_user_session_path
    end
  end

  private

  def check_approval(user)
    if user.has_role?(:superadmin) || (user.organization&.is_approved?)
      return true
    else
      flash[:alert] = "No approval is pending. First approve your organization, then try to login."
      redirect_to new_user_session_path
      return false
    end
  end
end