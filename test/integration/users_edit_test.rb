require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  setup do
    @user = users(:mike)
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), user: { name: @user.name,
                                      email: @user.email}
    assert_redirected_to login_url
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    patch user_path, user: {name: '',
                            email: 'mike@invalid',
                            password: '',
                            password_confirmation: ''}
    assert_template 'users/edit'
  end

  test "successful edit with friendly forwarding" do
    name = 'john'
    email = 'john@example.com'
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    assert_nil session[:forwarding_url]
    patch user_path(@user), user: { name: name,
                                email: email,
                                password: '',
                                password_confirmation: ''}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal @user.name, name
    assert_equal @user.email, email
  end
end
