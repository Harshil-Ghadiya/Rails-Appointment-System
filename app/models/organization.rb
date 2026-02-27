class Organization < ApplicationRecord
  has_many :users
  has_many :appointments
  has_many :booking_controls
  has_many :field_settings
  has_many :reserved_tokens
  has_many :notices
  validates :name, presence: true
  validates :email, presence: true, uniqueness: {message: "is alreay taken by another organization"} 
  validates :phone_number, presence: true, uniqueness: {message: "is already taken by another organization"}
end
