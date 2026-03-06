# new code 


class Appointment < ApplicationRecord
  belongs_to :organization

validates :patient_name, presence: true
validates :patient_phone, uniqueness: { 
    scope: [:organization_id, :session_name], 
    message: "has already booked an appointment in this session today" 
  }, if: -> { status != 'deleted' } 

  validates :patient_email, uniqueness: { 
    scope: [:organization_id, :session_name], 
    message: "has already been used for this session today"
  }, allow_blank: true, if: -> { status != 'deleted' }
  
  
  enum :status, { pending: 0, completed: 1, skipped: 2, deleted: 3 }, default: :pending

  before_create :generate_token
  
  after_commit :broadcast_to_tv, on: [ :create, :update, :destroy]

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

    # --- GAP FILLING LOGIC START ---
    # Aaj na badha active (non-deleted) tokens na number ni list lo
    existing_nums = organization.appointments
                                .where(created_at: Time.zone.now.all_day, session_name: self.session_name)
                                .where.not(status: :deleted)
                                .pluck(:token_number_only)

    # Reserved tokens ni list
    reserved_nums = organization.reserved_tokens.pluck(:token_number).map(&:to_i)

    # 1 thi start kari ne check karo ke sauthi pehlo khali number kayo che
    next_num = 1
    loop do
      # Jo number database ma (non-deleted) nathi ANE reserved pan nathi, to e free che!
      unless existing_nums.include?(next_num) || reserved_nums.include?(next_num)
        break
      end
      next_num += 1
    end
    # --- GAP FILLING LOGIC END ---

    self.token_number_only = next_num
    self.token_number = "#{prefix}-#{next_num}" 
  end

  private

  def broadcast_updates
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
                         partial: "tv_screens/queue_list", 
                         locals: { organization: organization }
  end
end




# old code 

# class Appointment < ApplicationRecord
#   belongs_to :organization
  
# enum :status, { pending: 0, completed: 1, skipped: 2, deleted: 3 }, default: :pending

#   before_create :generate_token
  
# after_commit :broadcast_to_tv, on: [ :create, :update, :destroy]


#   def generate_token
#     current_time = Time.zone.now
#     day_name = current_time.strftime("%A")
#     control = organization.booking_controls.find_by(day_name: day_name)
    
#     if control.present?
#       e_start_time = control.evening_start_time.strftime("%H:%M")
#       current_time_str = current_time.strftime("%H:%M")

#       if current_time_str < e_start_time
#         self.session_name = "Morning"
#       else
#         self.session_name = "Evening"
#       end
#       prefix = control.token_prefix || "T"
#     else
#       self.session_name = "Morning"
#       prefix = "T"
#     end

#     last_num = organization.appointments
#                            .where(created_at: Time.zone.now.all_day, session_name: self.session_name)
#                            .maximum(:token_number_only) || 0
                           
#     next_num = last_num + 1
    
#     while organization.reserved_tokens.exists?(token_number: next_num)
#       next_num += 1
#     end 

#     self.token_number_only = next_num
#     self.token_number = "#{prefix}-#{next_num}" 
#   end

#   private

#   def broadcast_updates
  
#     broadcast_remove_to "admin_dashboard_#{organization.id}", target: "appt_row_#{id}"

#     # Target table nakki karo
#     target_id = case status
#                 when 'completed' then "completed_appointments"
#                 when 'skipped', 'deleted' then "skipped_appointments"
#                 else "pending_appointments"
#                 end

#     # Navi row umero
#     broadcast_append_to "admin_dashboard_#{organization.id}", 
#                         target: target_id, 
#                         partial: "admin/dashboard/appointment_row", 
#                         locals: { appt: self }
#   end

# def broadcast_to_tv
  
#   broadcast_replace_to "tv_channel_#{organization_id}", 
#                          target: "tv_token_list",
#                          partial: "tv_screens/queue_list", 
#                          locals: { organization: organization }
# end
# end
