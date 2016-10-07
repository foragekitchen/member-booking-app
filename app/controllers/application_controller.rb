class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  rescue_from Exception do |exception|
    Rails.logger.info '*' * 100
    Rails.logger.info "Error: #{$!.class.name} -- #{exception.message.inspect}"
    Rails.logger.info "Backtrace: #{exception.backtrace.join("\n")}"
    Rails.logger.info '*' * 100

    error
  end

  before_action :check_session, except: [:error]
  before_action :set_coworker, only: [:error]

  def check_session
    return redirect_to_login('Please log in.') unless session[:user_id]
    session[:expiry_time] ||= Time.zone.now

    if session[:expiry_time] < (ENV['EXPIRED_PERIOD'] || 15).to_i.minutes.ago
      redirect_to_login("Looks like you might've stepped away for a bit. Log in again to continue!")
    elsif set_coworker
      session[:expiry_time] = Time.zone.now
    else
      redirect_to_login('You cannot login into the system. Please contact administrator for further instructions')
    end
  end

  def error
    respond_to do |format|
      format.html { render status_code.to_s, status: status_code }
      format.all { render nothing: true, status: status_code }
    end
  end

  def current_user
    @coworker
  end

  private

  def set_coworker
    @coworker = Coworker.find_by_user(session[:user_id]) if session[:user_id].present?
    if @coworker.try(:extra_service)
      cookies[:user] = @coworker
    else
      false
    end
  end

  def redirect_to_login(message = nil)
    reset_session
    flash[:info] = message
    respond_to do |format|
      format.html { redirect_to login_url }
      format.js { render 'shared/unauthorized' }
    end
  end

  def status_code
    params[:code] || 500
  end
end
