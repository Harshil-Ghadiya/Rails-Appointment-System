class Admin::ReservedTokensController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :authenticate_user!
  before_action :ensure_admin

  def index
    @reserved_tokens = current_user.organization.reserved_tokens.order(:token_number)
  end

  def create
    @reserved_token = current_user.organization.reserved_tokens.new(reserved_token_params)
    
    respond_to do |format|
      if @reserved_token.save
        flash.now[:notice] = "Token #{@reserved_token.token_number} has been reserved!"
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend("flash-container", partial: "layouts/flash"),
            turbo_stream.append("tokens_list", partial: "admin/reserved_tokens/token", locals: { rt: @reserved_token }),
            turbo_stream.replace("reserve_form", partial: "admin/reserved_tokens/form"),
            turbo_stream.remove("no_tokens_msg")
          ]
        end
        format.html { redirect_to admin_reserved_tokens_path }
      else
        flash.now[:alert] = "Token already reserved or invalid."
        format.turbo_stream { render turbo_stream: turbo_stream.prepend("flash-container", partial: "layouts/flash") }
        format.html { redirect_to admin_reserved_tokens_path }
      end
    end
  end

  def destroy
    @token = current_user.organization.reserved_tokens.find(params[:id])
    token_num = @token.token_number
    @token.destroy
    flash.now[:notice] = "Token #{token_num} is now available for patients!"

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.prepend("flash-container", partial: "layouts/flash"),
          turbo_stream.remove(dom_id(@token))
        ]
      end
      format.html { redirect_to admin_reserved_tokens_path, status: :see_other }
    end
  end

  private

  def reserved_token_params
    params.require(:reserved_token).permit(:token_number)
  end

  def ensure_admin
    unless current_user.has_role?(:admin)
      flash[:alert] = "Access Denied!"
      redirect_to root_path
    end
  end
end