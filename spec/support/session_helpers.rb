module SessionHelpers

  def execute_valid_login
    #TODO - need to eventually DRY this up with the user_signed_in? method
    #i.e. only do if session[:user_id] isn't defined yet
    visit login_path
    fill_in 'Email', with: Rails.application.secrets.nexudus_username
    fill_in 'Password', with: Rails.application.secrets.nexudus_password
    click_button "Log in"
  end

end