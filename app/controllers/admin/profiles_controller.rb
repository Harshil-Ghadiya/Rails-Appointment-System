class Admin::ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    
    if params[:user][:password].blank?
      flash.now[:alert] = "Password cannot be blank."
      return render_turbo_flash
    end

    if @user.update(user_params)
      bypass_sign_in(@user)
      redirect_to admin_dashboard_path, notice: "Password changed successfully!"
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render_turbo_flash
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def render_turbo_flash
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.prepend("flash-container", partial: "layouts/flash")
      end
      format.html { render :edit, status: :unprocessable_entity }
    end
  end

  def ensure_admin
    unless current_user.has_role?(:admin)
      flash[:alert] = "Access Denied! You are not authorized."
      redirect_to root_path
    end
  end
end