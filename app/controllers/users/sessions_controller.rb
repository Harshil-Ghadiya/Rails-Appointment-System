class Users::SessionsController < Devise::SessionsController

  skip_before_action :require_no_authentication, only: [:create]
  skip_before_action :authenticate_user!, only: [:new, :create]

  def create
    user = User.find_by(email: params[:user][:email])
    
    if user&.valid_password?(params[:user][:password])
      # Check Approval
      if user.has_role?(:superadmin) || (user.organization&.is_approved?)
        # Ahiya 'notice' vapro jethi success message ave
    
        # OTP Logic
        otp = rand(100000..999999).to_s
        user.update(otp_code: otp)
        
        begin
          TwilioService.send_otp(user.phone_number, otp)
          session[:otp_user_id] = user.id
         return redirect_to verify_otp_path, notice: "OTP sent to your mobile!"
        rescue => e
          flash[:alert] = "Error sending SMS: #{e.message}"
           return redirect_to new_user_session_path
          setup_resource_for_form 
          render :new, status: :unprocessable_entity
        end
      else
        # UNAPPROVED CASE
        flash[:alert] = "No approval is pending. First approve your organization, then try to login."
         return redirect_to new_user_session_path
        setup_resource_for_form
        render :new, status: :unprocessable_entity
      end
    else
      # WRONG PASSWORD
      flash[:alert] = "Invalid Email or Password or Mobile Number."
      return redirect_to new_user_session_path
      setup_resource_for_form
      render :new, status: :unprocessable_entity
    end
  end

  private


  def setup_resource_for_form
    self.resource = User.new(
      name: params[:user][:name],
      email: params[:user][:email],
      phone_number: params[:user][:phone_number],
      address: params[:user][:address]
    )
  end
end