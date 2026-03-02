class Admin::TvScreensController < ApplicationController
  layout "application" 

  def show
    @organization = Organization.find(params[:id])
  end
end