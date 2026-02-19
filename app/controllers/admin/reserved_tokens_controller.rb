class Admin::ReservedTokensController < ApplicationController
  def index
    @reserved_tokens = current_user.organization.reserved_tokens
  end

  def create
    current_user.organization.reserved_tokens.create(reserved_token: params[:reserved_token])
    redirect_to admin_reserved_tokens_path, notice: "Token Reserved!"
  end

  def destroy
    current_user.organization.reserved_tokens.find(params[:id]).destroy
    redirect_to admin_reserved_tokens_path, notice: "Token Removed!"
  end
end
