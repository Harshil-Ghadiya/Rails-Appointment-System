class BookingControl < ApplicationRecord
  belongs_to :organization

  after_update_commit :broadcast_schedule_changes

private 

def broadcast_schedule_changes
    broadcast_replace_to "admin_dashboard_#{organization_id}",
                         target: "booking_schedule_container",
                         partial: "admin/booking_controls/schedule_table",
                         locals: { booking_controls: organization.booking_controls.order(:id) }
  end
end
