class ReservedToken < ApplicationRecord
  belongs_to :organization

  validates :token_number, presence: true, 
            uniqueness: { scope: :organization_id, message: "is already reserved" },
            numericality: { only_integer: true, greater_than: 0 }
end
