class Admin::NoticesController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :authenticate_user!
  before_action :ensure_admin

  def index
    @notices = current_user.organization.notices.order(created_at: :desc)
    @notice = Notice.new 
  end

  def create
    @notice = current_user.organization.notices.new(notice_params)
    respond_to do |format|
      if @notice.save
        flash.now[:notice] = "Notice added successfully!"
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend("flash-container", partial: "layouts/flash"),
            turbo_stream.prepend("notices_list", partial: "admin/notices/notice", locals: { notice: @notice }),
            turbo_stream.remove("no_notices_msg"),
            turbo_stream.replace("notice_form_container", partial: "admin/notices/form", locals: { notice: Notice.new })
          ]
        end
        format.html { redirect_to admin_notices_path }
      else


        flash.now[:alert] = @notice.errors.full_messages.to_sentence
        
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend("flash-container", partial: "layouts/flash")
        end
        
        format.html { render :index, status: :unprocessable_entity }
        
      end
    end
  end

  def destroy
    @notice = current_user.organization.notices.find(params[:id])
    @notice.destroy
    flash.now[:notice] = "Notice deleted successfully!"

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.prepend("flash-container", partial: "layouts/flash"),
          turbo_stream.remove(dom_id(@notice))
        ]
      end
      format.html { redirect_to admin_notices_path, status: :see_other }
    end
  end

  private
  def notice_params
    params.require(:notice).permit(:content, :notice_type)
  end

  def ensure_admin
    unless current_user.has_role?(:admin)
      flash[:alert] = "Access Denied!"
      redirect_to root_path
    end
  end
end