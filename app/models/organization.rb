class Organization < ApplicationRecord
  has_many :users
  has_many :appointments
  has_many :booking_controls
  has_many :field_settings
  has_many :reserved_tokens
  has_many :notices
  validates :name, presence: true
  validates :email, presence: true, uniqueness: {message: "is alreay taken by another organization"} 
  validates :phone_number, presence: true


  after_commit :broadcast_status_updates, on: :update
after_update_commit :broadcast_doctor_status, if: :saved_change_to_doctor_status?

private

  def broadcast_status_updates
    broadcast_replace_to "admin_dashboard_#{id}", 
                         target: "admin_controls_section", 
                         partial: "admin/dashboard/controls", 
                         locals: { organization: self }
  end


def broadcast_doctor_status
  status_html = "<span style='color: #e65100; font-weight: bold;'>👨‍⚕️ DOCTOR STATUS: </span>" \
                "<span style='background: #ff9800; color: white; padding: 4px 12px; border-radius: 20px; font-size: 14px;'>" \
                "#{doctor_status || 'Available'}</span>"

  broadcast_update_to "patient_info_channel_#{id}",
                      target: "doctor_status_display",
                      html: status_html
end


  def broadcast_error_message(message)
    broadcast_prepend_to "admin_dashboard_#{id}",
                         target: "flash-container",
                         partial: "layouts/flash",
                         locals: { alert: message }
  end
  
end
