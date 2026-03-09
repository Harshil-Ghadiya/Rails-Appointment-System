class FieldSetting < ApplicationRecord
  belongs_to :organization
after_commit :broadcast_field_changes, on: :update


private   

def broadcast_field_changes
  broadcast_replace_to "admin_dashboard_#{organization_id}",
                         target: "field_settings_container",
                         partial: "admin/field_settings/settings_form",
        locals: { settings: organization.field_settings.order(:created_at) } # created_at vapro
end 
end
