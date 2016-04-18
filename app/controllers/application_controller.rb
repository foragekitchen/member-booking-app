class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :check_session

  def check_session
    return redirect_to_login('Please log in.') unless session[:user_id]
    session[:expiry_time] ||= Time.now

    if session[:expiry_time] < (ENV['EXPIRED_PERIOD'] || 15).to_i.minutes.ago
      redirect_to_login("Looks like you might've stepped away for a bit. Log in again to continue!")
    else
      if (@coworker = Coworker.find_by_user(session[:user_id]))
        session[:expiry_time] = Time.now
      else
        redirect_to_login('You cannot login into the system. Please contact administrator for further instructions')
      end
    end
  end

  private
  def redirect_to_login(message = nil)
    reset_session
    flash[:info] = message
    respond_to do |format|
      format.html { redirect_to login_path }
      format.js { render 'shared/unauthorized' }
    end
  end

end
