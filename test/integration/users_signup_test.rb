require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "invalid sign up" do
    get signup_path
    assert_no_difference 'User.count' do
      post_via_redirect users_path, user: {name: "",
                              email: 'user@invalid',
                              password: "foo",
                              password_field: "bar"}
    end
    assert_template "users/new"
    assert_select '#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "valid sign up" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, user: {name: 'valid',
                              email: 'valid@example.com',
                              password: 'mike1234',
                              password_confirmation: 'mike1234'}
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # 激活之前登陆
    log_in_as(user)
    assert_not is_logged_in?
    # 激活令牌无效
    get edit_account_activation_path("invalid token")
    assert_not is_logged_in?
    # 令牌有效, 邮箱无效
    get edit_account_activation_path(user.activation_token, email: 'invalid@example.com')
    assert_not is_logged_in?
    # 令牌邮箱均有效
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert is_logged_in?
    assert_template 'users/show'
    assert_not flash.empty?
  end
end
