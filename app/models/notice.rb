class Notice < ApplicationRecord
include ActionView::RecordIdentifier  
  belongs_to :organization
enum :notice_type, { general: 0, booking_window: 1 }
validates :content, presence: true

after_create_commit :broadcast_notice_creation
after_destroy_commit :broadcast_notice_removal


private 

def broadcast_notice_creation
    broadcast_prepend_to "admin_dashboard_#{organization_id}",
                         target: "notices_list",
                         partial: "admin/notices/notice",
                         locals: { notice: self }
    
    broadcast_remove_to "admin_dashboard_#{organization_id}", target: "no_notices_msg"
  end

  def broadcast_notice_removal
    broadcast_remove_to "admin_dashboard_#{organization_id}", target: dom_id(self)

    if self.organization.notices.empty?
      broadcast_append_to "admin_dashboard_#{organization_id}",
                          target: "notices_list",
                          html: '<p id="no_notices_msg" style="color: #bdc3c7;">No notices posted yet.</p>'.html_safe
    end
  end
end
