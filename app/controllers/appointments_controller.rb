class AppointmentsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
 before_action :check_org_status, only: [:new, :create, :show]


  def new
    @organization = Organization.find(params[:id])
    today_name = Time.now.strftime("%A")
    @settings = @organization.field_settings.where(is_required: true).pluck(:field_name)
    @booking_control = @organization.booking_controls.find_by(day_name: today_name)

    # Req 5: Check Start/Stop
    if @organization.is_booking_stopped
      return redirect_to root_path, alert: "Booking is currently stopped by the Hospital."
    end

    # Req 3: Check Time
    if @booking_control.present?
    current_time_str = Time.now.strftime("%H:%M") 
   is_morning = current_time_str < @booking_control.evening_start_time.strftime("%H:%M")


  if is_morning
        start_t = @booking_control.morning_start_time.strftime("%H:%M")
        end_t   = @booking_control.morning_end_time.strftime("%H:%M")
        @session_label = "Morning"
      else
        start_t = @booking_control.evening_start_time.strftime("%H:%M")
        end_t   = @booking_control.evening_end_time.strftime("%H:%M")
        @session_label = "Evening"
      end


      unless current_time_str.between?(start_t, end_t)
        return redirect_to root_path, alert: "Booking for #{today_name} is only open between #{start_t} and #{end_t}."
      end 
    else
      return redirect_to root_path, alert: "Hospital is closed today (#{today_name})."
    end
    
    @appointment = @organization.appointments.new
    @field_settings = @organization.field_settings
    @notices = @organization.notices.where(notice_type: ['booking_window', 'general'])
  end


def check_org_status
  org_id = params[:organization_id] || params[:id] || (params[:appointment] && params[:appointment][:organization_id])
  @organization = Organization.find_by(id: org_id)

if @organization.nil? && params[:id]
      @appointment = Appointment.find_by(id: params[:id])
      @organization = @appointment&.organization
    end

  if @organization.nil?
    redirect_to root_path, alert: "Organization not found."
  elsif !@organization.is_approved
    render plain: "This organization is currently inactive. Please contact the administrator.", status: :forbidden
  end
end



  def create
    @organization = Organization.find(params[:appointment][:organization_id])
    @appointment = @organization.appointments.new(appointment_params)

   today_name = Time.now.strftime("%A")
    control = @organization.booking_controls.find_by(day_name: today_name)
    current_time_str = Time.now.strftime("%H:%M")

    session_name = (current_time_str < control.evening_start_time.strftime("%H:%M")) ? "Morning" : "Evening"
    @appointment.session_name = session_name

last_token_record = @organization.appointments
                                 .where(created_at: Time.zone.now.all_day, session_name: session_name)
                                 .maximum(:token_number_only)

    last_token = last_token_record ? last_token_record.to_i : 0
    next_token = last_token + 1

    # 2. Reserved Tokens logic (Tamara schema pramane column 'token_number' che)
    # Ahiya pluck(:token_number) vaparyu che
reserved_nums = @organization.reserved_tokens.pluck(:token_number).map(&:to_i)
    # 3. Skip loop
    while reserved_nums.include?(next_token)
      next_token += 1
    end

@appointment.token_number_only = next_token
    @appointment.token_number = "#{control.token_prefix}-#{next_token}"
    @appointment.status = "pending"
    
    if @appointment.save
      redirect_to appointment_path(@appointment), notice: 'appointment booked Successfully'
    else

      today_name = Time.now.strftime("%A")
      @booking_control = control
      @field_settings = @organization.field_settings
      @notices = @organization.notices.where(notice_type: 'booking_window')
      render :new
    end
  end






def show
  @appointment = Appointment.find(params[:id])
  @organization = @appointment.organization
  
  # 1. Now Serving (Minimum Pending)
  @current_serving = @organization.appointments
                                  .where(status: :pending, created_at: Time.zone.now.all_day,
                                  session_name: @appointment.session_name) # AA LINE MAIN CHE
                                  .minimum(:token_number_only) || 0

  # 2. Smart Last Token Logic
  actual_max = @organization.appointments
                            .where(created_at: Time.zone.now.all_day,
                            session_name: @appointment.session_name) # AA LINE PAN JARURI CHE
                            .maximum(:token_number_only) || 0

  display_last = actual_max > 0 ? actual_max - 1 : 0

  while @organization.reserved_tokens.exists?(token_number: display_last) && display_last > 0
    display_last -= 1
  end

  @last_token = display_last
end

  private

  def appointment_params
    params.require(:appointment).permit(:patient_name, :patient_email, :patient_phone, :patient_address, :organization_id)
  end
end

