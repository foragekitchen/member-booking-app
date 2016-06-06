class ApplicationController < ActionController::Base
  ERROR_ACTIONS = [:not_found, :changes_rejected, :internal_server_error]

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :check_session, except: ERROR_ACTIONS
  before_action :set_coworker, only: ERROR_ACTIONS

  def check_session
    return redirect_to_login('Please log in.') unless session[:user_id]
    session[:expiry_time] ||= Time.zone.now

    if session[:expiry_time] < (ENV['EXPIRED_PERIOD'] || 15).to_i.minutes.ago
      redirect_to_login("Looks like you might've stepped away for a bit. Log in again to continue!")
    elsif (@coworker = Coworker.find_by_user(session[:user_id]))
      session[:expiry_time] = Time.zone.now
    else
      redirect_to_login('You cannot login into the system. Please contact administrator for further instructions')
    end
  end

  def not_found
    render(status: 404)
  end

  def changes_rejected
    render(status: 422)
  end

  def internal_server_error
    render(status: 500)
  end

  private

  def set_coworker
    @coworker = Coworker.find_by_user(session[:user_id]) if session[:user_id].present?
  end

  def redirect_to_login(message = nil)
    reset_session
    flash[:info] = message
    respond_to do |format|
      format.html { redirect_to login_path }
      format.js { render 'shared/unauthorized' }
    end
  end
end
