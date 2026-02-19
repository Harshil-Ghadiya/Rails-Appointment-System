class Notice < ApplicationRecord
  belongs_to :organization
enum notice_type: { general: 0, booking_window: 1 }, _suffix: true
end
