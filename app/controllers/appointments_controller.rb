class AppointmentsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def new
    @organization = Organization.find(params[:org_id])
    today_name = Time.now.strftime("%A")
    @booking_control = @organization.booking_controls.find_by(day_name: today_name)

    # Req 5: Check Start/Stop
    if @organization.is_booking_stopped
      return redirect_to root_path, alert: "Booking is currently stopped by the Hospital."
    end

    # Req 3: Check Time
    if @booking_control.present?
      current_time = Time.now.strftime("%H:%M")
      start_t = @booking_control.start_time.strftime("%H:%M")
      end_t = @booking_control.end_time.strftime("%H:%M")

      unless current_time.between?(start_t, end_t)
        return redirect_to root_path, alert: "Booking for #{today_name} is only open between #{start_t} and #{end_t}."
      end
    else
      return redirect_to root_path, alert: "Hospital is closed today (#{today_name})."
    end
    
    @appointment = @organization.appointments.new
    @field_settings = @organization.field_settings
    @notices = @organization.notices.where(notice_type: 'booking_window')
  end

  def create
    @organization = Organization.find(params[:appointment][:organization_id])
    @appointment = @organization.appointments.new(appointment_params)

 last_token_record = @organization.appointments.where(created_at: Time.zone.now.all_day).maximum(:token_number)
    last_token = last_token_record ? last_token_record.to_i : 0
    next_token = last_token + 1

    # 2. Reserved Tokens logic (Tamara schema pramane column 'token_number' che)
    # Ahiya pluck(:token_number) vaparyu che
reserved_nums = @organization.reserved_tokens.pluck(:token_number).map(&:to_i)
    # 3. Skip loop
    while reserved_nums.include?(next_token)
      next_token += 1
    end

    @appointment.token_number = next_token
    @appointment.status = "pending"

    if @appointment.save
      redirect_to appointment_path(@appointment)
    else
      today_name = Time.now.strftime("%A")
      @booking_control = @organization.booking_controls.find_by(day_name: today_name)
      @field_settings = @organization.field_settings
      @notices = @organization.notices.where(notice_type: 'booking_window')
      render :new
    end
  end

  def show
    @appointment = Appointment.find(params[:id])
    @organization = @appointment.organization
    
    # Req 1, 2, 5: Live Stats
last_serving_token = @organization.appointments.where(status: 'complete', created_at: Time.zone.now.all_day).last&.token_number
    @current_serving = last_serving_token ? last_serving_token.to_i : 0
    
    max_token = @organization.appointments.where(created_at: Time.zone.now.all_day).maximum(:token_number)
    @last_token = max_token ? max_token.to_i : 0
  end

  private

  def appointment_params
    params.require(:appointment).permit(:patient_name, :patient_email, :patient_phone, :patient_address, :organization_id)
  end
end