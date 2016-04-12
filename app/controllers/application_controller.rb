class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :check_session
  
  def check_session
    if session[:user_id]
      session[:expiry_time] ||= Time.now
      if session[:expiry_time] < 15.minutes.ago
        reset_session
        flash[:info] = "Looks like you might've stepped away for a bit. Log in again to continue!"  
        redirect_to login_path
      else
        File.open('tmp/log.log', 'a') {|f| f.write("ZZZ CHECK: #{session[:user_id].inspect}\n")}
        @coworker = Coworker.find_by_user(session[:user_id])
        session[:expiry_time] = Time.now
      end
    else
      #... authenticate
      session[:expiry_time] = Time.now
      flash[:info] = 'Please log in.' 
      redirect_to login_path
    end
  end

end
