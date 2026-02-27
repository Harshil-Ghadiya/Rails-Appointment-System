class Admin::ProfilesController < ApplicationController
    before_action :authenticate_user!
      before_action :ensure_admin

  def edit; @user = current_user;
 end

  def update
    @user = current_user
    if @user.update(params.require(:user).permit(:password, :password_confirmation))
      bypass_sign_in(@user)
      redirect_to admin_dashboard_path, notice: "Password changed successfully!"
    else
      render :edit
    end
  end

  def ensure_admin
    unless current_user.has_role?(:admin)
      flash[:alert] = "Access Denied! You are not authorized."
      redirect_to root_path
    end
  end
  

end

