require 'test_helper'

class PasswodsResetTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  setup do
    ActionMailer::Base.deliveries.clear
    @user = users(:mike)
  end

  test 'password reset' do
    get new_password_path
    assert_template 'passwords/new'
    # 电子邮箱无效
    post passwords_path, {email: ""}
    assert_not flash.empty?
    assert_template 'passwords/new'
    # 电子邮箱有效, 但账号未激活
    @user.toggle!(:activated)
    post passwords_path, email: @user.email
    assert_not flash.empty?
    assert_nil assigns(:user).reset_token
    assert_redirected_to login_url
    # 电子邮箱有效且账号已经激活
    @user.toggle!(:activated)
    post passwords_path, email: @user.email
    assert_not flash.empty?
    assert_not_nil assigns(:user).reset_token
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_redirected_to login_url

    # 密码重置表单
    @user = assigns(:user)
    # 电子邮件错误
    get edit_password_path(@user.reset_token, email: '')
    assert_not flash.empty?
    assert_redirected_to root_url
    # 用户未激活
    @user.toggle!(:activated)
    get edit_password_path(@user.reset_token, email: @user.email)
    assert_redirected_to root_url
    # 邮箱正确，重置令牌错误
    @user.toggle!(:activated)
    get edit_password_path('why', email: @user.email)
    assert_redirected_to root_url
    # 一切正常
    get edit_password_path(@user.reset_token, email: @user.email)
    assert_template 'passwords/edit'
    assert_select 'input[name=email][type=hidden][value=?]', @user.email

    # 密码为空
    patch password_path(@user.reset_token),
      email: @user.email,
      user: {password:'', password_confirmation: ''}
    assert_not flash.empty?
    assert_template 'passwords/edit'
    assert_select 'div#error_explanation', count: 0

    # 密码或密码确认无效
    patch password_path(@user.reset_token),
      email: @user.email,
      user: {password: '1234', password_confirmation: '1234'}
    assert_template 'passwords/edit'
    assert_select 'div#error_explanation'

    # 密码和密码确认有效
    patch password_path(@user.reset_token),
      email: @user.email,
      user: {password: '12345678', password_confirmation: '12345678'}
    assert_not flash.empty?
    assert is_logged_in?
    assert_redirected_to @user
  end
end
