class RemoveOtpCodeFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :otp_code   
  end
end
