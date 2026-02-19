class Admin::NoticesController < ApplicationController
  before_action :authenticate_user!

  def index
    @notices = current_user.organization.notices.order(created_at: :desc)
  end

  def create
    @notice = current_user.organization.notices.new(
      content: params[:content], 
      notice_type: params[:notice_type].to_i
    )
    
    if @notice.save
      redirect_to admin_notices_path, notice: "Notice published successfully!"
    else
      redirect_to admin_notices_path, alert: "Error publishing notice."
    end
  end

  def destroy
    @notice = current_user.organization.notices.find(params[:id])
    @notice.destroy
    redirect_to admin_notices_path, notice: "Notice deleted!"
  end
end