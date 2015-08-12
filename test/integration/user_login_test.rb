require 'test_helper'

class UserLoginTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  setup do
    @user = users(:mike)
    @other_user = users(:jordan)
  end

  test "log in with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: {email:'aaa@test', password:'123'}
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "log in with valid information followed by log out" do
    get login_path
    post login_path, session: {email: @user.email, password: 'password'}
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', logout_path
    # assert_select 'a[href=?]', user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_path
    follow_redirect!
    assert_select 'a[href=?]', logout_path, count: 0
    assert_select 'a[href=?]', login_path

    # 模拟在另一个窗口退出
    delete logout_path
    follow_redirect!
    assert_select 'a[href=?]', logout_path, count: 0
    assert_select 'a[href=?]', login_path
  end

  test "log in with remember me" do
    log_in_as(@user, remember_me: '1')
    assert_not_nil cookies['remember_token']
  end

  test "log in without remember me" do
    log_in_as(@user, remember_me: '0')
    assert_nil cookies['remember_token']
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert_redirected_to root_path
  end

  test "should redirect update when logged in as wrong user"  do
    log_in_as(@other_user)
    patch user_path(@user), user: {name: @user.name, email: @user.email}
    assert_redirected_to root_path
  end

end
