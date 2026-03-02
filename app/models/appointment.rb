class Appointment < ApplicationRecord
  belongs_to :organization
  
enum :status, { pending: 0, completed: 1, skipped: 2, deleted: 3 }, default: :pending

  before_create :generate_token
  
after_commit :broadcast_to_tv, on: [:update, :destroy]

  def generate_token
    current_time = Time.zone.now
    day_name = current_time.strftime("%A")
    control = organization.booking_controls.find_by(day_name: day_name)
    
    if control.present?
      e_start_time = control.evening_start_time.strftime("%H:%M")
      current_time_str = current_time.strftime("%H:%M")

      if current_time_str < e_start_time
        self.session_name = "Morning"
      else
        self.session_name = "Evening"
      end
      prefix = control.token_prefix || "T"
    else
      self.session_name = "Morning"
      prefix = "T"
    end

    last_num = organization.appointments
                           .where(created_at: Time.zone.now.all_day, session_name: self.session_name)
                           .maximum(:token_number_only) || 0
                           
    next_num = last_num + 1
    
    while organization.reserved_tokens.exists?(token_number: next_num)
      next_num += 1
    end 

    self.token_number_only = next_num
    self.token_number = "#{prefix}-#{next_num}" 
  end

  private

  def broadcast_updates
    # Juni row kadho
    broadcast_remove_to "admin_dashboard_#{organization.id}", target: "appt_row_#{id}"

    # Target table nakki karo
    target_id = case status
                when 'completed' then "completed_appointments"
                when 'skipped', 'deleted' then "skipped_appointments"
                else "pending_appointments"
                end

    # Navi row umero
    broadcast_append_to "admin_dashboard_#{organization.id}", 
                        target: target_id, 
                        partial: "admin/dashboard/appointment_row", 
                        locals: { appt: self }
  end

def broadcast_to_tv
  
  broadcast_replace_to "tv_channel_#{organization_id}", 
                         target: "tv_token_list",
                         partial: "admin/tv_screens/queue_list", 
                         locals: { organization: organization }
end
end
