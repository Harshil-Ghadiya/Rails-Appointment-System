class Admin::ReservedTokensController < ApplicationController
  before_action :authenticate_user!

  def index
    # Order ma pan 'token_number' vapro
    @reserved_tokens = current_user.organization.reserved_tokens.order(:token_number)
  end

  def create
    # Ahiya 'token_number' lakhvu padse karan ke table ma e naam che
    @reserved_token = current_user.organization.reserved_tokens.new(reserved_token_params)
    
    if @reserved_token.save
      return redirect_to admin_reserved_tokens_path, notice: "Token #{params[:token_number]} has been reserved!"
    else
      redirect_to admin_reserved_tokens_path, alert: "Token already reserved or invalid."
    end
  end

  def destroy
    @token = current_user.organization.reserved_tokens.find(params[:id])
    @token.destroy
    redirect_to admin_reserved_tokens_path, notice: "#{params[:token_number]}TokenNumber is Available for Patients!"
  end
 
  private

  # Strong parameters
  def reserved_token_params
    params.require(:reserved_token).permit(:token_number)
  end

end