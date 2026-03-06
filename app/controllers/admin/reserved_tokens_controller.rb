class Admin::ReservedTokensController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :authenticate_user!
  before_action :ensure_admin

  def index
    @reserved_tokens = current_user.organization.reserved_tokens.order(:session_name, :token_number)
  end

  def create
    current_session = determine_session(current_user.organization)
    num = reserved_token_params[:token_number].to_i

    @reserved_token = current_user.organization.reserved_tokens.new(reserved_token_params)
    @reserved_token.session_name = current_session 

    is_already_booked = current_user.organization.appointments
                                    .where(created_at: Time.zone.now.all_day)
                                    .where(session_name: current_session)
                                    .where(token_number_only: num)
                                    .where.not(status: :deleted)
                                    .exists?

    respond_to do |format|
      if is_already_booked
        flash.now[:alert] = "Error: Token #{num} is already booked in #{current_session} session!"
        format.turbo_stream { render turbo_stream: turbo_stream.prepend("flash-container", partial: "layouts/flash") }
        format.html { redirect_to admin_reserved_tokens_path }
        
      elsif @reserved_token.save
        flash.now[:notice] = "Token #{@reserved_token.token_number} has been reserved for #{current_session}!"
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
        flash.now[:alert] = "This token number is already reserved in #{current_session} list!"
        format.turbo_stream { render turbo_stream: turbo_stream.prepend("flash-container", partial: "layouts/flash") }
        format.html { redirect_to admin_reserved_tokens_path }
      end
    end
  end

  def destroy
    @token = current_user.organization.reserved_tokens.find(params[:id])
    token_num = @token.token_number
    session_nm = @token.session_name
    @token.destroy
    flash.now[:notice] = "Token #{token_num} (#{session_nm}) is now available!"

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

  def determine_session(org)
    current_time = Time.zone.now
    day_name = current_time.strftime("%A")
    control = org.booking_controls.find_by(day_name: day_name)
    
    if control.present?
      e_start_time = control.evening_start_time.strftime("%H:%M")
      current_time_str = current_time.strftime("%H:%M")
      current_time_str < e_start_time ? "Morning" : "Evening"
    else
      "Morning"
    end
  end

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

