class ReservedToken < ApplicationRecord
  include ActionView::RecordIdentifier
  belongs_to :organization

  validates :token_number, presence: true, 
            uniqueness: { scope: :organization_id, message: "is already reserved" },
            numericality: { only_integer: true, greater_than: 0 }

  after_create_commit :broadcast_token_addition
  after_destroy_commit :broadcast_token_removal

  private 

  def broadcast_token_addition
    broadcast_append_to "admin_dashboard_#{organization_id}",
                        target: "tokens_list",
                        partial: "admin/reserved_tokens/token",
                        locals: { rt: self }
    
    broadcast_remove_to "admin_dashboard_#{organization_id}", target: "no_tokens_msg"
  end

  def broadcast_token_removal
    broadcast_remove_to "admin_dashboard_#{organization_id}", target: dom_id(self)

    if self.organization.reserved_tokens.empty?
      broadcast_prepend_to "admin_dashboard_#{organization_id}",
                           target: "tokens_list",
                           html: '<p id="no_tokens_msg" style="color: #bdc3c7;">No tokens reserved yet.</p>'.html_safe
    end
  end
end