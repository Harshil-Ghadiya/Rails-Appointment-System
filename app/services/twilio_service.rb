require 'twilio-ruby'

class TwilioService
  def self.send_otp(phone_number)
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    
    # Fakt phone number j moklavano che, code Twilio pote handle karshe
    client.verify.v2.services(ENV['TWILIO_VERIFY_SERVICE_SID'])
          .verifications
          .create(to: "+91#{phone_number}", channel: 'sms')
  rescue Twilio::REST::RestError => e
    puts "Twilio Error: #{e.message}"
    raise e
  end

  def self.check_otp(phone_number, otp_code)
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    
    # Ahiya be arguments joiye: phone ane user e nakhrelo code
    verification_check = client.verify.v2.services(ENV['TWILIO_VERIFY_SERVICE_SID'])
                               .verification_checks
                               .create(to: "+91#{phone_number}", code: otp_code)
    
    verification_check.status == 'approved'
  rescue Twilio::REST::RestError => e
    puts "Twilio Verification Error: #{e.message}"
    false
  end
end