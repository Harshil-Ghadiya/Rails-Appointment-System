class Admin::ProfilesController < ApplicationController
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
end

