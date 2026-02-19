class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :lockable, :timeoutable, :trackable
   rolify
  belongs_to :organization, optional: true
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :phone_number, presence: true, uniqueness: true
  validates :address, presence: true
validates  :password, presence: true, confirmation: true, on: :create
  def active_for_authentication?

    return true if has_role?(:superadmin)
    super && organization&.nil? || organization&.is_approved?
  end

  def inactive_message 
    if organization.present? && !organization.is_approved?
      "Your organization is not approved yet. Please contact support."
    else
      super 
    end
  end
end
