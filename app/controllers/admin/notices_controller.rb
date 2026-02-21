class Admin::NoticesController < ApplicationController
  before_action :authenticate_user!

  def index
    @notices = current_user.organization.notices.order(created_at: :desc)
    @notice = Notice.new # Form mate
  end

  def create
    @notice = current_user.organization.notices.new(notice_params)
    if @notice.save
      redirect_to admin_notices_path, notice: "Notice added successfully!"
    else
      redirect_to admin_notices_path, alert: "Content can't be blank."
    end
  end

  def destroy
    @notice = current_user.organization.notices.find(params[:id])
    @notice.destroy
    redirect_to admin_notices_path, notice: "Notice deleted!", status: :see_other
  end

  private

  def notice_params
    params.require(:notice).permit(:content, :notice_type)
  end
end