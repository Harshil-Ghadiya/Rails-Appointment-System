class Admin::FieldSettingsController < ApplicationController
  before_action :authenticate_user!
      before_action :ensure_admin


  def index
    @organization = current_user.organization
    
    required_fields = ['patient_name', 'patient_email', 'patient_phone', 'patient_address']
    
    required_fields.each do |field|
      unless @organization.field_settings.exists?(field_name: field)
        @organization.field_settings.create(field_name: field, is_required: true)
      end
    end

    @settings = @organization.field_settings.order(:created_at)
  end


def update_all
  selected_count = params[:fields].values.count { |v| v[:is_required] == "1" }

  if selected_count == 0
    flash.now[:alert] = "Error: Please select at least one field."
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.prepend("flash-container", partial: "layouts/flash") }
      format.html { redirect_to admin_field_settings_path, alert: flash.now[:alert] }
    end
  else
    params[:fields].each do |id, val|
      setting = current_user.organization.field_settings.find(id)
      setting.update(is_required: val[:is_required] == "1") 
    end

    @settings = current_user.organization.field_settings.order(:created_at)
    flash.now[:notice] = "Form settings updated successfully!"

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.prepend("flash-container", partial: "layouts/flash"),
          turbo_stream.replace("field_settings_container", partial: "admin/field_settings/settings_form", locals: { settings: @settings })
        ]
      end
      format.html { redirect_to admin_field_settings_path, notice: flash.now[:notice] }
    end
  end
end 


   def ensure_admin
    unless current_user.has_role?(:admin)
      flash[:alert] = "Access Denied! You are not authorized."
      redirect_to root_path
    end
  end
end

