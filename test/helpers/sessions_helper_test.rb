require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  setup do
    @user = users(:mike)
    remember(@user)
  end

  test "current_user return right user when session is nil" do
    assert_equal current_user, @user
    assert is_logged_in?
  end

  test "current_user return nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end
