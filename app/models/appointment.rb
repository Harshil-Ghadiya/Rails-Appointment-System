class Appointment < ApplicationRecord
  belongs_to :organization
  
  # Rails 7 style enum
  enum :status, { pending: 0, completed: 1, skipped: 2, deleted: 3 }, default: :pending

  # Importance: Automatically generate token before saving to DB
  before_create :generate_token

  def generate_token
    # Prefix check: if booking_control exists use it, else default to 'T'
    control = organization.booking_controls.first
    prefix = control&.token_prefix || "T"
    
    # Get last number for this organization
    last_num = organization.appointments.maximum(:token_number_only) || 0
    next_num = last_num + 1
    
    # Requirement 4: Skip reserved tokens
    while organization.reserved_tokens.exists?(token_number: next_num)
      next_num += 1
    end

    self.token_number_only = next_num
    self.token_number = "#{prefix}-#{next_num}" # Example: M-1, M-2
  end
end