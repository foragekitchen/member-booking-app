module ApplicationHelper
  def user_signed_in?
    @coworker.present?
    # session[:user_id].present? && session[:user_id].is_a?(Integer)
  end

  def google_calendar_link(title, opts = {})
    text = opts[:text] || 'Your booking'
    website = opts[:website] || 'www.foragekitchen.com'
    location = opts[:location] || '478 25TH ST, OAKLAND, CA'
    render partial: 'shared/google_calendar_link', locals: {title: title,
                                                            text: URI.escape(text),
                                                            date_from: opts[:date_from],
                                                            date_to: opts[:date_to],
                                                            website: URI.escape(website),
                                                            location: URI.escape(location)}
  end
end
