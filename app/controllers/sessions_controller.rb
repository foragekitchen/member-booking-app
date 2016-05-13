class SessionsController < ApplicationController
  skip_before_action :check_session, only: [:new, :create]

  def new
  end

  def create
    reset_session
    result = User.authenticate(params[:session][:email].downcase, params[:session][:password])
    if result.is_a?(User)
      session[:user_id] = result.id
      redirect_to resources_path
    else
      flash[:alert] = result['Message']
      render 'new'
    end
  end

  def destroy
    reset_session
    flash[:notice] = 'Thanks for logging out.'
    redirect_to login_path
  end
end
