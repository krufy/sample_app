require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:mike)
  end

  test "account_activate" do
    @user.activation_token = User.new_token
    mail = UserMailer.account_activate(@user)
    assert_equal "Account activate", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["13011024902@163.com"], mail.from
    assert_match @user.name, mail.body.encoded
    assert_match @user.activation_token, mail.body.encoded
    assert_match CGI::escape(@user.email), mail.body.encoded
  end

  test "password_reset" do
    @user.reset_token = User.new_token
    mail = UserMailer.password_reset(@user)
    assert_equal "Password reset", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["13011024902@163.com"], mail.from
    assert_match @user.name, mail.body.encoded
    assert_match @user.reset_token, mail.body.encoded
    assert_match CGI::escape(@user.email), mail.body.encoded
  end

end
