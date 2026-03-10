class BookingControl < ApplicationRecord
  belongs_to :organization
  has_many :booking_slots, dependent: :destroy
  accepts_nested_attributes_for :booking_slots, allow_destroy: true,
  reject_if: proc { |attributes| attributes['start_time'].blank? || attributes['end_time'].blank? }
  after_update_commit :broadcast_schedule_changes

private 

def broadcast_schedule_changes
    broadcast_replace_to "admin_dashboard_#{organization_id}",
                         target: "booking_schedule_container",
                         partial: "admin/booking_controls/schedule_table",
                         locals: { booking_controls: organization.booking_controls.order(:id) }
  end
end
