module ApplicationHelper
  def user_signed_in?
    @coworker.present?
    # session[:user_id].present? && session[:user_id].is_a?(Integer)
  end
end
