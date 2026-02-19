# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


# Ek Super Admin user banavo
super_admin = User.find_or_create_by!(email: 'superadmin@gmail.com') do |user|
  user.name = "Super Admin"
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.phone_number = '1234567890'
  user.address = 'Head Office'
  user.confirmed_at = Time.now # Jo confirmable vaprta ho to
end

# Ene superadmin role aapo (Rolify)
super_admin.add_role(:superadmin)
puts "Super Admin Created: email: superadmin@gmail.com, password: password123"
