class Admin::FieldSettingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @organization = current_user.organization
    
    # 1. Badha jaroori fields ni list
    required_fields = ['patient_name', 'patient_email', 'patient_phone', 'patient_address']
    
    required_fields.each do |field|
      unless @organization.field_settings.exists?(field_name: field)
        @organization.field_settings.create(field_name: field, is_required: true)
      end
    end

    @settings = @organization.field_settings.order(:created_at)
  end

  def update_all
    # 2. Pehla check karo ke ketla select thaya che
    # Params mathi values kadhi ne count karo ke "1" ketli vaar che
    selected_count = params[:fields].values.count { |v| v[:is_required] == "1" }

    if selected_count == 0
      flash[:alert] = "Error: Please select at least one field for the booking form."
      redirect_to admin_field_settings_path
    else
      params[:fields].each do |id, val|
        setting = current_user.organization.field_settings.find(id)
        setting.update(is_required: val[:is_required] == "1") 
      end
      redirect_to admin_field_settings_path, notice: "Form settings updated successfully!"
    end
  end
end