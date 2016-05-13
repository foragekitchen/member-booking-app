require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Authenticating (for logging in)' do
    it 'should return a user ID to store in the session and identify the user when inputted email/password is valid' do
      user = User.authenticate('patti@foragesf.com', 'correctpassword')
      expect(user.id).to eq(100)
    end
  end
end
