class Users::RegistrationsController < Devise::RegistrationsController
  def new 
    super 
  end

 def create
    # Organization create 
    @organization = Organization.new(
      name: params[:user][:name],
      email: params[:user][:email],
      phone_number: params[:user][:phone_number],
      address: params[:user][:address],
      is_approved: false 
    )

    if @organization.save
      default_password = params[:user][:phone_number]
      @user = User.new(
        name: params[:user][:admin_name],
        email: params[:user][:email],
        password: default_password,
        password_confirmation:default_password,
        phone_number: params[:user][:phone_number],
        address: params[:user][:address],
        organization_id: @organization.id 
      )

      if @user.save
        @user.add_role :admin
        flash[:notice] = "Organization Registered. Please wait for Super Admin approval."
        redirect_to new_user_session_path
      else
        @organization.destroy 
        build_resource(sign_up_params)
        flash.now[:alert] = @user.errors.full_messages.join(", ")
        self.resource = User.new # Fresh User object
      @organization = Organization.new # Fresh Organization object
        render :new,  status: :unprocessable_entity
      end

    else
      build_resource(sign_up_params)
      flash.now[:alert] = @organization.errors.full_messages.join(", ")
      self.resource = User.new # Fresh User object
      @organization = Organization.new # Fresh Organization object
      render :new, status: :unprocessable_entity
    end
  end
end

