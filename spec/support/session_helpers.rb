module SessionHelpers

  def execute_valid_login
    #TODO - need to eventually DRY this up with the user_signed_in? method
    #i.e. only do if session[:user_id] isn't defined yet
    visit login_path
    # Note this uses a COWORKER's login, since the API-user login is only an Admin that has type User/Contact. 
    # We need an actual Coworker to accurately create member bookings; Coworkers are different from Users and Contacts in the Nexudus world
    fill_in 'Email', with: Rails.application.secrets.nexudus_test_username
    fill_in 'Password', with: Rails.application.secrets.nexudus_test_password
    click_button "Log in"
  end

end