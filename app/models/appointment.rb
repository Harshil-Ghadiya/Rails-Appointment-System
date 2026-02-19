class Appointment < ApplicationRecord
  belongs_to :organization
  enum status: { pending: 0, completed: 1, skipped: 2, deleted: 3 }
end
