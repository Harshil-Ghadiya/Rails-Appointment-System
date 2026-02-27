class Appointment < ApplicationRecord
  belongs_to :organization
  
  # Rails 7 style enum
  enum :status, { pending: 0, completed: 1, skipped: 2, deleted: 3 }, default: :pending

  # Importance: Automatically generate token before saving to DB
  before_create :generate_token
  
  after_update_commit -> {
  # 1. Pela row ne Juni jagya e thi kadho
  broadcast_remove_to "admin_dashboard_#{organization.id}", target: "appt_row_#{id}"

  # 2. Navi jagya e umero status mujab
  target_id = case status
              when 'completed' then "completed_appointments"
              when 'skipped', 'deleted' then "skipped_appointments"
              else "pending_appointments"
              end

  broadcast_append_to "admin_dashboard_#{organization.id}", 
    target: target_id, 
    partial: "admin/dashboard/appointment_row", 
    locals: { appt: self }
}


  def generate_token

    current_time = Time.zone.now
    self.session_name = current_time.hour < 14 ? "Morning" : "Evening"
    # Prefix check: if booking_control exists use it, else default to 'T'
    day_name = current_time.strftime("%A")
    control = organization.booking_controls.find_by(day_name: day_name)
    prefix = control&.token_prefix || "T"

    # Get last number for this organization
    last_num = organization.appointments
                   .where(created_at: Time.zone.now.all_day, session_name: self.session_name)
                   .maximum(:token_number_only) || 0
                   
      next_num = last_num + 1
    
    # Requirement 4: Skip reserved tokens
    while organization.reserved_tokens.exists?(token_number: next_num)
      next_num += 1
    end 

    self.token_number_only = next_num
    self.token_number = "#{prefix}-#{next_num}" # Example: M-1, M-2
  end
end
