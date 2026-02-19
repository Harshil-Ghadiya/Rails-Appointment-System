class Admin::FieldSettingsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @organization = current_user.organization
    @settings = @organization.field_settings
  

  if @settings.empty?
      ['patient_name', 'patient_email', 'patient_phone'].each do |field|
        @organization.field_settings.create(field_name: field, is_required: true) 
      end
      @settings = @organization.field_settings.reload
    end
  end
  
def update_all
    params[:fields].each do |id, val|
      FieldSetting.find(id).update(is_required: val[:is_required] == "1")
    end
    redirect_to admin_field_settings_path, notice: "Patient form fields updated successfully!"
  end
end