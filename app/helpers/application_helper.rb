module ApplicationHelper

  def user_signed_in?
    session[:user_id].present? && session[:user_id].is_a?(Integer)
  end

end
