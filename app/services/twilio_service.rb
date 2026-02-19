require 'twilio-ruby'

class TwilioService
  def self.send_otp(phone_number, otp)
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

    client.messages.create(
      from: ENV['TWILIO_PHONE_NUMBER'], 
      to: phone_number, 
      body: "Tamaro Appointment System Login OTP: #{otp}. not share any other."
    )
  rescue Twilio::REST::RestError => e
    puts "Twilio Error: #{e.message}"
    return false
  end
end